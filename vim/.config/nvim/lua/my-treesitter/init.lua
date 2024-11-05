local M = {}

local top_level_declaration_nodes = {
  java = {
    class_declaration = true,
    enum_declaration = true,
    interface_declaration = true,
    record_declaration = true,
  },
  go = {
    const_declaration = true,
    function_declaration = true,
    method_declaration = true,
    type_declaration = true,
    var_declaration = true,
  },
}

-- Select the first top level declaration node using treesitter. This should then position
-- the cursor on a class, enum, record, interface in Java or a const, type, var, function
-- and method declaration in Go https://go.dev/ref/spec#Declarations_and_scope.
M.top_level_declaration = function()
  if not top_level_declaration_nodes[vim.bo.filetype] then
    return
  end

  local ts_utils = require('nvim-treesitter.ts_utils')
  local _, tree = ts_utils.get_root_for_position(0, 0)
  if tree == nil then
    return
  end

  for node, _ in tree:root():iter_children() do
    if top_level_declaration_nodes[vim.bo.filetype][node:type()] ~= nil then
      local row = node:start() + 1
      vim.api.nvim_win_set_cursor(0, { row, 0 })
      return
    end
  end
end

---@param language string language to use for the query
---@param name string
---
---@return vim.treesitter.Query : parsed query
M.get_query = function(language, name)
  local query_path = vim.env.DOTFILES
    .. '/vim/.config/nvim/queries/'
    .. language
    .. '/'
    .. name
    .. '.scm'
  local query_content = vim.fn.readfile(query_path)
  -- return vim.treesitter.query.parse(language, table.concat(query_content, '\n'))

  -- TODO get test names, then move this into my Go plugin as a function?
  -- TODO launch terminal with go test from git project root and test name regex
  local custom_query = vim.treesitter.query.parse(language, table.concat(query_content, '\n'))
  local bufnr = 0
  local parser = vim.treesitter.get_parser(bufnr, 'go') -- Assuming you're working on a Lua file
  local tree = parser:parse()[1]
  for id, node, metadata in custom_query:iter_captures(tree:root(), bufnr) do
    -- Process matches found by your custom query
    Print(vim.treesitter.get_node_text(node, bufnr))
  end
end

-- Folds
-- TODO move language specific functions somewhere else? or structure them differently?

--- Converts a variable argument list into a set-like table.
---
--- @param ... any elements to add to the set
--- @return table<string, boolean> a set table where each argument is a key with the value `true`
local function vararg_to_set(...)
  local set = {}
  for _, v in ipairs({ ... }) do
    set[v] = true
  end
  return set
end

-- Count the number of direct children of interest. This is necessary to discard any nodes like '[',
-- ']', '{' , '}' or comments.
---
--- @param ... string treesitter node types of children to be counted
--- @return fun(node: TSNode?): integer counts the number of children of given node
local function children_counter(...)
  local types = vararg_to_set(...)

  return function(node)
    local count = 0

    if node == nil then
      --- @return integer
      return count
    end

    for n in node:iter_children() do
      if types[n:type()] then
        count = count + 1
      end
    end
    --- @return integer
    return count
  end
end

local json_count_children = children_counter('object', 'array', 'pair')

-- Returns a string summarizing given node.
--
---@param node TSNode|nil
---@return string
local function json_foldtext(node)
  if node == nil then
    return ''
  end

  local bufnr = 0
  if node:type() == 'string' then
    return vim.treesitter.get_node_text(node, bufnr)
  elseif node:type() == 'pair' then
    local key = node:field('key')[1]
    local value = node:field('value')[1]
    return json_foldtext(key) .. ': ' .. json_foldtext(value)
  elseif node:type() == 'object' then
    local pair = node:child(1)
    local text = '{' .. json_foldtext(pair)
    if json_count_children(node) > 1 then
      text = text .. '...'
    end
    text = text .. '}'
    return text
  elseif node:type() == 'array' then
    local count = json_count_children(node)
    if count == 0 then
      return '[]'
    elseif count == 1 then
      return '[ 1 element ]'
    else
      return '[' .. count .. ' elements ]'
    end
  end

  return ''
end

local yaml_count_children = children_counter('block_mapping_pair', 'block_sequence_item')

-- Returns a string summarizing given node.
--
---@param node TSNode|nil
---@return string
local function yaml_foldtext(node)
  if node == nil then
    return ''
  end

  local bufnr = 0
  if node:type() == 'plain_scalar' or node:type() == 'flow_node' then
    return vim.treesitter.get_node_text(node, bufnr)
  elseif node:type() == 'block_mapping_pair' then
    local key = node:field('key')[1]
    local value = node:field('value')[1]
    return yaml_foldtext(key) .. ': ' .. yaml_foldtext(value)
  elseif node:type() == 'block_node' then
    -- is this a bug? why can I not get the first child of a block_node like this but using an
    -- iterator? This does work for JSON
    -- local child = node:child(1)
    local child = node:iter_children()()
    if child == nil then
      return 'no child'
    end

    -- TODO is that correct or do I need to deal with this in another way?
    if not child then
      return 'block_node must have children'
    end
    local type = child:type()
    if not (type == 'block_mapping' or type == 'block_sequence') then
      return "expected one of 'block_mapping' or 'block_sequence, got '" .. type .. ' instead'
    end

    local count = yaml_count_children(child)
    local chars = {
      block_mapping = {
        separator_open = '{',
        separator_close = '}',
        descriptor = 'key',
      },
      block_sequence = {
        separator_open = '[',
        separator_close = ']',
        descriptor = 'item',
      },
    }
    local text = chars[type].separator_open
    if count == 1 then
      text = text .. ' 1 ' .. chars[type].descriptor .. ' '
    else
      text = text .. ' ' .. count .. ' ' .. chars[type].descriptor .. 's '
    end
    text = text .. chars[type].separator_close
    return text
  end

  return 'unknown'
end

-- Summarize folds created by treesitter using treesitter.
local foldtext = {
  -- Example foldtext:
  -- pair with array value: {"trackedEntities": [1 element]}
  -- object:                {"orgUnit": "O6uvpzGd5pu"...}
  json = function()
    local node = vim.treesitter.get_node({ bufnr = 0, pos = { vim.v.foldstart, 0 } })
    if node == nil then
      return ''
    end

    local folds = vim.treesitter.query.get('json', 'folds')
    if folds == nil then
      vim.notify("my-treesitter: failed finding folds for language 'json'", vim.log.levels.ERROR)
      return ''
    end
    local _, first_fold = folds:iter_captures(node, 0, node:start(), node:start() + 1)()
    if first_fold == nil then
      return ''
    end

    if first_fold:type() == 'array' then
      local parent = first_fold:parent()
      if parent ~= nil then
        first_fold = parent
      end
    end

    local _, fold_col = first_fold:range()
    local indentation = string.rep(' ', fold_col)

    return indentation .. json_foldtext(first_fold)
  end,
  yaml = function()
    local node = vim.treesitter.get_node({ bufnr = 0, pos = { vim.v.foldstart, 0 } })
    if node == nil then
      return ''
    end

    local folds = vim.treesitter.query.get('yaml', 'folds')
    if folds == nil then
      vim.notify("my-treesitter: failed finding folds for language 'yaml'", vim.log.levels.ERROR)
      return ''
    end
    local _, first_fold = folds:iter_captures(node, 0, node:start(), node:start() + 1)()
    if first_fold == nil then
      return ''
    end

    local _, fold_col = first_fold:range()
    local indentation = string.rep(' ', fold_col)

    return indentation .. yaml_foldtext(first_fold)
  end,
}

-- Returns a foldtext function for given language to summarizing treesitter folds. Defaults to the
-- builtin vim foldtext() if no custom foldtext function is implemented for the language.
--
---@param language string
---@return fun(): string
M.foldtext = function(language)
  return foldtext[language] or vim.fn.foldtext
end

return M

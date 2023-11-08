local ts_locals = require('nvim-treesitter.locals')
local ts_utils = require('nvim-treesitter.ts_utils')

local get_node_text = vim.treesitter.get_node_text

local ins = function(value)
  print(vim.inspect(value))
end

local print_node = function(node, bufnr)
  ins(get_node_text(node, bufnr))
end

local function_node_types = {
  function_declaration = true,
  method_declaration = true,
  func_literal = true,
}

local get_function_node_at_cursor = function(bufnr)
  local cursor_node = ts_utils.get_node_at_cursor()
  local scope = ts_locals.get_scope_tree(cursor_node, bufnr)

  for _, v in ipairs(scope) do
    if function_node_types[v:type()] then
      return v
    end
  end

  return nil
end

local go_result_types = function(bufnr)
  local cursor_node = ts_utils.get_node_at_cursor()
  local scope = ts_locals.get_scope_tree(cursor_node, bufnr)

  local function_node
  for _, v in ipairs(scope) do
    ins(v:type())
    print_node(v, bufnr)
    if function_node_types[v:type()] then
      function_node = v
    end
  end

  print('found function node')
  print_node(function_node, bufnr)

  -- local language_tree = vim.treesitter.get_parser(bufnr, 'go')
  --   local language_tree = vim.treesitter.get_string_parser([[
  -- func withError() (int, error) {
  -- 	return 0, nil
  -- }
  --   ]], 'go')
  -- local syntax_tree = language_tree:parse()
  -- local root = syntax_tree[1]:root()
  -- print_node(root, bufnr)

  local result = {}
  -- TODO how to deal with errors? we should not end up not having a func as I use the
  -- show/condition to prevent this from being called
  -- local function_node = get_function_node_at_cursor(bufnr)
  -- if not function_node then
  --   print('Not inside of a function')
  --   return result
  -- end

  local query = vim.treesitter.query.parse(
    'go',
    [[
      [
        (method_declaration result: (parameter_list (parameter_declaration type: (type_identifier) @id)))
        (function_declaration result: (parameter_list (parameter_declaration type: (type_identifier) @id)))
        (func_literal result: (parameter_list (parameter_declaration type: (type_identifier) @id)))
      ]
    ]]
  )

  for _, node in query:iter_captures(function_node, bufnr) do
    print('found capture')
    -- ins(getmetatable(node))
    print_node(node, bufnr)
    -- table.insert(result, get_node_text(node[1], bufnr))

    -- local count = node:named_child_count()
    -- for idx = 0, count - 1 do
    -- local matching_node = node:named_child(idx)
    -- local type_node = matching_node:field('type')[1]
    -- if idx ~= count - 1 then
    --   table.insert(result, t({ ', ' }))
    -- end
    -- end
  end
end

local bufnr = vim.api.nvim_get_current_buf()
-- local language_tree = vim.treesitter.get_parser(bufnr, "go")
-- local syntax_tree = language_tree.parse()
-- i(language_tree)
go_result_types(bufnr)
--

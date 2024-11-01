-- TODO move most to my-treesitter module
-- TODO add type hints
-- TODO does this work as is for yaml?

-- Count the number of direct children like object, array or pairs.
local function child_count(node)
  local count = 0
  for n in node:iter_children() do
    if n:type() == 'object' or n:type() == 'array' or n:type() == 'pair' then
      count = count + 1
    end
  end
  return count
end

-- Returns a string summarizing given node.
local function foldtext(node)
  if node == nil then
    return ''
  end

  local bufnr = 0
  if node:type() == 'string' then
    return vim.treesitter.get_node_text(node, bufnr)
  elseif node:type() == 'pair' then
    local key = node:field('key')[1]
    local value = node:field('value')[1]
    return foldtext(key) .. ': ' .. foldtext(value)
  elseif node:type() == 'object' then
    local pair = node:child(1)
    local text = '{' .. foldtext(pair)
    if child_count(node) > 1 then
      text = text .. '...'
    end
    text = text .. '}'
    return text
  elseif node:type() == 'array' then
    local count = child_count(node)
    if count == 0 then
      return '[]'
    elseif count == 1 then
      return '[ 1 element ]'
    else
      return '[' .. count .. ' elements ]'
    end
  end
end

-- TODO indent text like the original node at that position
-- Summarize JSON folds created by treesitter using treesitter.
-- Example foldtext:
-- pair with array value: {"trackedEntities": [1 element]}
-- object:                {"orgUnit": "O6uvpzGd5pu"...}
function MyFoldtext()
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

  return foldtext(first_fold)
end

vim.opt.foldtext = 'v:lua.MyFoldtext()'
-- default
-- vim.opt.foldtext = vim.opt.foldtext._info.default

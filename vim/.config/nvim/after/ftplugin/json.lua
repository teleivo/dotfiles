-- TODO move most to my-treesitter module
-- TODO does this work as is for yaml?
-- TODO add type hint
-- Returns a string summarizing given node.
local function foldtext(node)
  -- TODO object: indicate with ... that there are more pairs or reuse the same logic for the array
  -- child count to indicate a count of pairs
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
    return '{' .. foldtext(pair) .. '}'
  elseif node:type() == 'array' then
    return '[]'
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
  local first_fold
  for _, n in folds:iter_captures(node, 0, node:start(), node:start() + 1) do
    first_fold = n
    break
  end

  if first_fold == nil then
    return ''
  end

  if first_fold:type() == 'array' then
    first_fold = first_fold:parent()
  end

  return foldtext(first_fold)
end

vim.opt.foldtext = 'v:lua.MyFoldtext()'
-- default
-- vim.opt.foldtext = vim.opt.foldtext._info.default

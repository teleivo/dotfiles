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
function MyFoldtext()
  -- root? same as first level?
  -- {"trackedEntities": [1 element]}
  -- {"orgUnit": "O6uvpzGd5pu"...}
  local foldstart = vim.v.foldstart
  local node = vim.treesitter.get_node({ bufnr = 0, pos = { foldstart, 0 } })
  local query = vim.treesitter.query.get('json', 'folds')
  local first_fold_capture_node
  for _, n in query:iter_captures(node, 0, node:start(), node:start() + 1) do
    first_fold_capture_node = n
    break
  end

  if first_fold_capture_node == nil then
    return ''
  end

  local result = first_fold_capture_node
  if first_fold_capture_node:type() == 'array' then
    result = first_fold_capture_node:parent()
  end

  return foldtext(result)
end

vim.opt.foldtext = 'v:lua.MyFoldtext()'
-- default
-- vim.opt.foldtext = vim.opt.foldtext._info.default

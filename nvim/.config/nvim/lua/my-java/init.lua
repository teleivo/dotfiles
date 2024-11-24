local M = {}

local tests_query

-- TODO enhance with position info and create class annotation
---@param bufnr integer? The bufnr to find tests in, defaults to the current buffer.
---@return table The list of test names.
function M.find_tests(bufnr)
  bufnr = bufnr or 0

  -- TODO cache again once its working
  -- if not tests_query then
  --   tests_query = require('my-treesitter').get_query('java', 'tests')
  -- end
  tests_query = require('my-treesitter').get_query('java', 'tests')

  local parser = vim.treesitter.get_parser(bufnr, 'java')
  if not parser then
    return {}
  end

  local tree = parser:parse()[1]
  if not tree then
    return {}
  end
  local root = tree:root()

  local tests = {}
  for _, match in tests_query:iter_matches(root, bufnr) do
    for id, nodes in pairs(match) do
      local name = tests_query.captures[id]
      if name == 'name' then
        for _, node in ipairs(nodes) do
          local test_name = vim.treesitter.get_node_text(node, bufnr)
          table.insert(tests, test_name)
        end
      end
    end
  end
  Print(tests)
  return tests
end

return M

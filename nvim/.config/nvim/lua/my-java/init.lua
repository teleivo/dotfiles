local M = {}

local tests_query

---@class (exact) JavaTest Test represents a JUnit 5 test.
---@field class string The class name the test is in.
---@field name string The name of the test method.
---@field start_row integer The one-indexed start row of the test method name.
---@field start_col integer The one-indexed start col of the test method name.

---@param bufnr integer? The bufnr to find tests in, defaults to the current buffer.
---@return JavaTest[] tests The list of tests in given buffer.
function M.find_tests(bufnr)
  bufnr = bufnr or 0

  if not tests_query then
    tests_query = require('my-treesitter').get_query('java', 'tests')
  end

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
    local test = {}
    for id, nodes in pairs(match) do
      local name = tests_query.captures[id]
      if name == 'class' then
        for _, node in ipairs(nodes) do
          test.class = vim.treesitter.get_node_text(node, bufnr)
        end
      elseif name == 'name' then
        for _, node in ipairs(nodes) do
          test.name = vim.treesitter.get_node_text(node, bufnr)
          local start_row, start_col = node:range()
          -- expose vim indexed row and col (TS uses zero-indexed ones)
          test.start_row = start_row + 1
          test.start_col = start_col + 1
        end
      end
    end
    table.insert(tests, test)
  end
  return tests
end

-- TODO I need to find the root maven, not sure if this is doing that
local root_markers = { 'gradlew', 'mvnw', '.git' }
local root_dir = vim.fs.root(0, root_markers) or vim.fs.root(0, { 'pom.xml' })
if not root_dir then
  return
end

-- TODO fix the method so it supports
-- mvn test --file dhis-2/pom.xml -Dsurefire.failIfNoSpecifiedTests=false "-Dtest=IdSchemeExportControllerTest"
-- mvn test --file dhis-2/pom.xml -Dsurefire.failIfNoSpecifiedTests=false "-Dtest=IdSchemeExportControllerTest#"
-- mvn test --file dhis-2/pom.xml
-- and passing additional args? like profiles?

---Runs tests using the 'go test' command.
---@param class string? Run tests inside this class.
---@param test string? Run this test method inside the class.
function M.mvn_test(class, test)
  local command = 'mvn test'
  if class then
    if test then
    end
  end
  command = command .. '\n'

  local term_job_id = require('my-neovim').open_terminal(root_dir)
  vim.fn.chansend(term_job_id, command)
end

return M

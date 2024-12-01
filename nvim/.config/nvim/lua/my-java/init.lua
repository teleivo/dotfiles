local M = {}

local tests_query

---@module "my-test"
---@class (exact) JavaTest: Test Test represents a JUnit 5 test.
---@field class string The class name the test is in.

---@param bufnr integer? The bufnr to find tests in, defaults to the current buffer.
---@return JavaTest[] tests The list of tests in given buffer.
function M.find_tests(bufnr)
  bufnr = bufnr or 0
  local path
  if bufnr == 0 then
    path = vim.fn.expand('%:p')
  else
    path = vim.fn.expand('#' .. bufnr .. ':p')
  end

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
          local start_row, start_col, end_row, end_col = node:range()
          -- expose vim indexed row and col (TS uses zero-indexed ones)
          test.start_row = start_row + 1
          test.start_col = start_col + 1
          test.end_row = end_row + 1
          test.end_col = end_col + 1
          test.path = path
        end
      end
    end
    table.insert(tests, test)
  end
  return tests
end

-- Finds the projects root directory. This does not have to be the root directory in a multi-module
-- maven project like DHIS2 where the root pom is located one level below the project roo
-- https://github.com/dhis2/dhis2-core/blob/master/dhis-2/pom.xml
function M.find_mvn_root_dir()
  local root_markers = { 'gradlew', 'mvnw', '.git' }
  return vim.fs.root(0, root_markers) or vim.fs.root(0, { 'pom.xml' })
end

-- TODO prettify this
---Find the root maven pom.xml.
local function find_root_pom(path, git_root)
  path = vim.uv.fs_realpath(path) or path
  local root_pom = nil
  while path and (not git_root or path:sub(1, #git_root) == git_root) do
    if vim.uv.fs_stat(path .. '/pom.xml') then
      root_pom = path .. '/pom.xml'
    end
    path = path:match('(.+)/[^/]+$')
  end
  return root_pom
end

local maven_root_dir = find_root_pom(vim.api.nvim_buf_get_name(0), project_root_dir)

---@class (exact) JavaTestArgs
---@field test JavaTest?
---@field test_args string[]?

---Generates the the 'mvn test' command.
---@param args JavaTestArgs Run this test.
---@return string The maven command to run the test.
function M.mvn_test(args)
  local command = 'mvn test'

  if args and args.test then
    command = command
      .. ' --file '
      .. maven_root_dir
      .. ' -Dsurefire.failIfNoSpecifiedTests=false "-Dtest='
      .. args.test.class
    if args.test.name then
      command = command .. '#' .. args.test.name
    end
    command = command .. '"'
  end

  return command
end

return M

local M = {}

--- Notify user of LSP error.
--- @param err lsp.ResponseError
local function handle_error(err)
  if not err then
    return
  end

  if err ~= nil and type(err[1]) == 'table' then
    for k, v in pairs(err[1]) do
      if k == 'error' then
        vim.notify('LSP : ' .. v.message, vim.log.levels.ERROR)
        break
      end
    end
  end
end

--- Returns the first LSP client for the given buffer.
--- @param name string LSP name
--- @param bufnr integer? bufnr to get lsp client for, defaults to current buffer
local function get_lsp_client(name, bufnr)
  return vim.lsp.get_clients({ name = name, bufnr = bufnr or 0 })[1]
end

--- Returns the Go module path as passed to go mod init https://go.dev/ref/mod#go-mod-init.
--- @return string go The Go module path.
local function go_list_module_path()
  local result = vim.system({ 'go', 'list', '-m' }):wait()
  if result.code ~= 0 then
    vim.notify(
      "Go: failed to retrieve Go module path using 'go list': " .. (result.stderr or ''),
      vim.log.levels.ERROR
    )
    return ''
  end

  return result.stdout:match('[^\r\n]+')
end

local project_go_module_path = go_list_module_path()

--- @class (exact) Package Package represents a Go package.
--- @field import_path string The import path of the package.
--- @field is_own boolean Indicates that the package is part of the projects own Go module.
--- @field is_stdlib boolean Indicates that the package is from Go's stdlib.
--- @field is_internal boolean Indicates that the package import path contains '/internal'.

--- List available packages.
--- @return Package[]
function M.go_list()
  local result = vim.system({ 'go', 'list', '-f', "'{{.ImportPath}} {{.Standard}}'", 'all' }):wait()
  if result.code ~= 0 then
    vim.notify(
      "Go: failed to retrieve Go import paths using 'go list': " .. (result.stderr or ''),
      vim.log.levels.ERROR
    )
    return {}
  end

  local packages = {}
  for line in result.stdout:gmatch('[^\r\n]+') do
    local import_path, is_stdlib = line:match("^'([^']+)%s([^']+)'$")
    is_stdlib = (is_stdlib == 'true')
    local is_own = import_path:match('^' .. project_go_module_path) ~= nil
    local is_internal = import_path:match('internal') ~= nil
    if not is_internal or (is_internal and is_own) then
      table.insert(packages, { import_path = import_path, is_stdlib = is_stdlib, is_own = is_own })
    end
  end
  return packages
end

--- Organize imports in current buffer.
--- Uses gopls (LSP) 'source.organizeImports'.
function M.organize_imports()
  pcall(function()
    vim.lsp.buf.code_action({
      context = { only = { 'source.organizeImports' }, diagnostics = {} },
      apply = true,
    })
  end)
end

--- Adds the given import to Go file in current buffer.
--- Uses gopls (LSP) command 'gopls.add_import'
--- https://github.com/golang/tools/blob/master/gopls/doc/commands.md#add-an-import
--- @param import_path string The import path to add like "fmt".
--- @param bufnr integer? The bufnr to add the import to, defaults to current buffer.
function M.import(import_path, bufnr)
  bufnr = bufnr or 0
  local uri = vim.uri_from_bufnr(bufnr)
  local command = {
    title = 'Add Go import',
    command = 'gopls.add_import',
    arguments = {
      {
        URI = uri,
        ImportPath = import_path,
      },
    },
  }
  local client = get_lsp_client('gopls', bufnr)
  client:exec_cmd(command, { bufnr = bufnr }, handle_error)
end

local gomod_path
local gomod_uri
local gomod_root

local function find_gomod_path()
  if gomod_path then
    return gomod_path
  end

  local file = vim.fn.findfile('go.mod', '.;')
  local path = vim.fn.fnamemodify(file, ':p')
  if path == nil then
    vim.notify('Failed to find go.mod', vim.log.levels.ERROR)
    return
  end
  gomod_path = path
  return gomod_path
end

local function find_gomod_uri()
  if gomod_uri then
    return gomod_uri
  end

  local path = find_gomod_path()
  if not path then
    return
  end

  gomod_uri = vim.uri_from_fname(path)
  return gomod_uri
end

function M.find_gomod_root_dir()
  if gomod_root then
    return gomod_root
  end

  local path = find_gomod_path()
  if not path then
    return
  end

  gomod_root = vim.fn.fnamemodify(path, ':h')
  return gomod_root
end

-- Add a dependency to the go.mod file. Uses gopls (LSP) command 'gopls.add_import'.
-- You can either pass the module path and version separately or pass them concatenated using @ like
-- so github.com/google/go-cmp@v0.6.0
-- It is also ok to pass a package path as the module path. So github.com/google/go-cmp/cmp will add
-- a require for module github.com/google/go-cmp.
-- https://github.com/golang/tools/blob/master/gopls/doc/commands.md#add-a-dependency
function M.gomod_add(module_path, module_version)
  local command_args = module_path
  if module_version then
    command_args = command_args .. '@' .. module_version
  end

  if not gomod_uri then
    gomod_uri = find_gomod_uri()
  end

  local command = {
    title = 'Add a dependency to Go mod',
    command = 'gopls.add_dependency',
    arguments = {
      {
        URI = gomod_uri,
        GoCmdArgs = { command_args },
        -- AddRequire = true,
      },
    },
  }
  local bufnr = 0
  local client = get_lsp_client('gopls', bufnr)
  client:exec_cmd(command, { bufnr = bufnr }, handle_error)
end

-- TODO this works if the go.mod is loaded in a buffer. It does not seem to work otherwise.
-- Run go mod tidy. Uses gopls (LSP) command 'gopls.tidy'.
-- https://github.com/golang/tools/blob/master/gopls/doc/commands.md#run-go-mod-tidy
function M.gomod_tidy()
  local command = {
    title = 'Run Go mod tidy',
    command = 'gopls.tidy',
    arguments = {
      {
        URIs = { gomod_uri },
      },
    },
  }
  local bufnr = 0
  local client = get_lsp_client('gopls', bufnr)
  client:exec_cmd(command, { bufnr = bufnr }, handle_error)
end

local tests_query

--- @module "my-test"
--- @class (exact) GoTest: Test Test represents a Go test function.

--- @param bufnr integer? The bufnr to find tests in, defaults to the current buffer.
--- @return GoTest[] tests The list of tests in given buffer.
function M.find_tests(bufnr)
  bufnr = bufnr or 0
  local path
  if bufnr == 0 then
    path = vim.fn.expand('%:p')
  else
    path = vim.fn.expand('#' .. bufnr .. ':p')
  end

  if not tests_query then
    tests_query = require('my-treesitter').get_query('go', 'tests')
  end

  local parser = vim.treesitter.get_parser(bufnr, 'go')
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
      if name == 'test' then
        for _, node in ipairs(nodes) do
          local start_row, start_col, end_row, end_col = node:range()
          -- expose vim indexed row and col (TS uses zero-indexed ones)
          test.start_row = start_row + 1
          test.start_col = start_col + 1
          test.end_row = end_row + 1
          test.end_col = end_col + 1
          test.path = path
        end
      elseif name == 'name' then
        for _, node in ipairs(nodes) do
          test.name = vim.treesitter.get_node_text(node, bufnr)
        end
      end
    end
    table.insert(tests, test)
  end
  return tests
end

--- @class (exact) GoTestArgs
--- @field test GoTest?
--- @field test_args string[]?

--- Generates the 'go test' command. Allows running a single test with or without additional args for
--- 'go test' as well as all tests with or without additional args to 'go test'.
--- @param args GoTestArgs The test and args for 'go test'.
--- @return string The 'go test' command to run the test.
function M.go_test(args)
  local command = 'go test ./...'

  if args and args.test then
    command = command .. ' -run ' .. args.test.name
  end

  if args and args.test_args and #args.test_args > 0 then
    command = command .. ' ' .. table.concat(args.test_args, ' ')
  end

  return command
end

-- Keep one terminal/buffer per file. The idea is that scratch buffers get their own terminal but at
-- least right now they still have the same project directory which is odd. Not sure yet how to deal
-- with that.
local terminals = {}

-- TODO when should I clean up these jobs :joy:
-- TODO autoscroll does not always seem to work
-- TODO why does golangci crash all the time?
-- TODO run go code in a range: 1. go run needs a file, where to put it? tempfile will also need a
-- copy of go.mod
--
--- Run Go in current buffer showing the output in a preview window.
function M.go_run()
  local neovim = require('my-neovim')
  local file = vim.fn.expand('%:p')
  local command = 'go run ' .. file .. '\n'

  if not terminals[file] or not vim.api.nvim_buf_is_valid(terminals[file].bufnr) then
    local job_id, bufnr = neovim.open_terminal(M._project_dir, M._keymaps)
    terminals[file] = { job_id = job_id, bufnr = bufnr }
  end

  -- ensure preview window is open and autoscroll is on
  local bufnr = terminals[file].bufnr
  if not neovim.is_buffer_visible(bufnr) then
    neovim.open_preview_window(bufnr, M._project_dir)
    neovim.auto_scroll_to_end(bufnr)
  end

  vim.fn.chansend(terminals[file].job_id, command)
end

return M

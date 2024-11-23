---Notify user of LSP error.
---@param err lsp.ResponseError
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

---Returns the first LSP client for given buffer.
---@param name string LSP name
---@param bufnr integer? bufnr to get lsp client for, defaults to current buffer
local function get_lsp_client(name, bufnr)
  return vim.lsp.get_clients({ name = name, bufnr = bufnr or 0 })[1]
end

---Returns the Go module path as passed to go mod init https://go.dev/ref/mod#go-mod-init.
---@return string go module path
local function module_path()
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

local module = module_path()

-- TODO add docs for the package format and use it in return
---List available packages.
local function go_list()
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
    local is_own = import_path:match('^' .. module) ~= nil
    local is_internal = import_path:match('internal') ~= nil
    if not is_internal or (is_internal and is_own) then
      table.insert(packages, { import_path = import_path, is_stdlib = is_stdlib, is_own = is_own })
    end
  end
  return packages
end

---Add import to Go file in current buffer. Uses gopls (LSP) command 'gopls.add_import'.
---https://github.com/golang/tools/blob/master/gopls/doc/commands.md#add-an-import
---@param import_path string import path like "fmt" to add
---@param bufnr integer? bufnr to add import to, defaults to current buffer
local function import(import_path, bufnr)
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

local function find_go_mod_path()
  local go_mod_file = vim.fn.findfile('go.mod', '.;')
  local go_mod_path = vim.fn.fnamemodify(go_mod_file, ':p')
  if go_mod_path == nil then
    vim.notify('Failed to find go.mod', vim.log.levels.ERROR)
    return
  end
  return go_mod_path
end

local function find_go_mod_uri()
  return vim.uri_from_fname(find_go_mod_path())
end

local function find_go_mod_root()
  return vim.fn.fnamemodify(find_go_mod_path(), ':h')
end

-- Add a dependency to the go.mod file. Uses gopls (LSP) command 'gopls.add_import'.
-- You can either pass the module path and version separately or pass them concatenated using @ like
-- so github.com/google/go-cmp@v0.6.0
-- It is also ok to pass a package path as the module path. So github.com/google/go-cmp/cmp will add
-- a require for module github.com/google/go-cmp.
-- https://github.com/golang/tools/blob/master/gopls/doc/commands.md#add-a-dependency
local function add_dependency(module_path, module_version)
  local go_mod_uri = find_go_mod_uri()
  local command_args = module_path
  if module_version then
    command_args = command_args .. '@' .. module_version
  end

  local command = {
    title = 'Run Go mod tidy',
    command = 'gopls.add_dependency',
    arguments = {
      {
        URI = go_mod_uri,
        GoCmdArgs = { command_args },
        -- AddRequire = true,
      },
    },
  }
  local bufnr = 0
  local client = get_lsp_client('gopls', bufnr)
  client:exec_cmd(command, { bufnr = bufnr }, handle_error)
end

-- Run go mod tidy. Uses gopls (LSP) command 'gopls.tidy'.
-- https://github.com/golang/tools/blob/master/gopls/doc/commands.md#run-go-mod-tidy
local function gomod_tidy()
  local go_mod_uri = find_go_mod_uri()

  local command = {
    title = 'Run Go mod tidy',
    command = 'gopls.tidy',
    arguments = {
      {
        URIs = { go_mod_uri },
      },
    },
  }
  local bufnr = 0
  local client = get_lsp_client('gopls', bufnr)
  client:exec_cmd(command, { bufnr = bufnr }, handle_error)
end

-- TODO cache the query instead of doing io every time
---@param bufnr integer? find tests in bufnr or current buffer
---@return table list of test names
local function find_tests(bufnr)
  bufnr = bufnr or 0
  local custom_query = require('my-treesitter').get_query('go', 'tests')

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
  for _, match in custom_query:iter_matches(root, bufnr) do
    for id, nodes in pairs(match) do
      local name = custom_query.captures[id]
      if name == 'name' then
        for _, node in ipairs(nodes) do
          local test_name = vim.treesitter.get_node_text(node, bufnr)
          table.insert(tests, test_name)
        end
      end
    end
  end
  return tests
end

---@param bufnr integer
local function auto_scroll_to_end(bufnr)
  -- Ensure the buffer is valid and loaded
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.notify('Invalid or unloaded buffer: ' .. bufnr, vim.log.levels.ERROR)
    return
  end

  -- Set an autocmd to track updates to the buffer
  vim.api.nvim_create_autocmd({ 'BufWritePost', 'TextChanged', 'TextChangedI' }, {
    buffer = bufnr,
    callback = function()
      if vim.api.nvim_get_current_buf() == bufnr then
        -- Scroll to the end if the buffer is active in the current window
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        vim.api.nvim_win_set_cursor(0, { line_count, 0 })
      end
    end,
    desc = 'Automatically scroll to end of buffer',
  })
end

---@param bufnr integer
---@return boolean
local function is_buffer_visible(bufnr)
  -- is buffer already visible?
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      return true
    end
  end

  return false
end

---@param bufnr integer
local function open_window(bufnr)
  if is_buffer_visible(bufnr) then
    return
  end

  local height = math.ceil(vim.o.lines * 0.35) -- 40% of screen height
  local width = math.ceil(vim.o.columns * 0.4) -- 40% of screen width
  local win = vim.api.nvim_open_win(bufnr, true, {
    split = 'below',
    style = 'minimal',
    width = width,
    height = height,
  })
  vim.api.nvim_win_set_buf(win, bufnr)
  vim.cmd('lcd ' .. vim.fn.fnameescape(find_go_mod_root()))
end

-- TODO clean up my global state/shadowing mess here
local bufnr
local term_job_id

---@param buffer_name string
---@return integer bufnr which displays terminal
---@return integer job_id of the terminal job
local function open_terminal(buffer_name)
  local bufnr = vim.api.nvim_create_buf(true, true)

  open_window(bufnr)

  vim.api.nvim_set_current_buf(bufnr)
  local job_id = vim.fn.termopen(vim.o.shell, {
    on_exit = function(_, exit_code, _)
      print('Terminal exited with code:', exit_code)
    end,
  })
  vim.api.nvim_buf_set_name(bufnr, buffer_name)
  auto_scroll_to_end(bufnr)
  return bufnr, job_id
end

-- TODO how to reuse most and make it work for java?

-- TODO allow selection of a test with vim.ui or telescope? start simple. telescope is nice as it
-- could have a preview of the actual test on the right
-- TODO find_tests (or list_tests) could find tests in current buffer by default and a list of
-- buffers. combined with a function to find_test_buffers I could populate telescope with all tests
-- of currently open buffers. This helps when I want to stay in the impl and run a specific test
-- TODO fix find_... funcs and type hints and null checks
-- TODO fix deprecated API calls

---Runs tests using the 'go test' command.
---@param run string? run regexp passed to the 'go test' commands '-run' flag
---@param ... string? any additional flags passed to the 'go test' command
local function go_test(run, ...)
  local buffer_name = 'go://tests'
  if not term_job_id then
    bufnr, term_job_id = open_terminal(buffer_name)
  else
    open_window(bufnr)
  end

  local command = 'go test ./...'
  if run then
    command = command .. ' -run ' .. run
  end
  local args = { ... }
  if #args > 0 then
    command = command .. ' ' .. table.concat(args, ' ')
  end
  command = command .. '\n'

  vim.fn.chansend(term_job_id, command)
end

return {
  import = import,
  go_list = go_list,
  add_dependency = add_dependency,
  gomod_tidy = gomod_tidy,
  go_test = go_test,
  find_tests = find_tests,
}

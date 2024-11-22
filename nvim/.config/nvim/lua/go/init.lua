local function handle_error(msg)
  if msg ~= nil and type(msg[1]) == 'table' then
    for k, v in pairs(msg[1]) do
      if k == 'error' then
        vim.notify('LSP : ' .. v.message, vim.log.levels.ERROR)
        break
      end
    end
  end
end

-- Add import to Go file in current buffer. Uses gopls (LSP) command 'gopls.add_import'.
-- https://github.com/golang/tools/blob/master/gopls/doc/commands.md#add-an-import
local function add_import(import_path)
  local bufnr = vim.api.nvim_get_current_buf()
  local uri = vim.uri_from_bufnr(bufnr)
  local command_params = {
    command = 'gopls.add_import',
    arguments = {
      {
        URI = uri,
        ImportPath = import_path,
      },
    },
  }
  local resp = vim.lsp.buf.execute_command(command_params)
  handle_error(resp)
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

  local command_params = {
    command = 'gopls.add_dependency',
    arguments = {
      {
        URI = go_mod_uri,
        GoCmdArgs = { command_args },
        -- AddRequire = true,
      },
    },
  }
  local resp = vim.lsp.buf.execute_command(command_params)
  handle_error(resp)
end

-- Run go mod tidy. Uses gopls (LSP) command 'gopls.tidy'.
-- https://github.com/golang/tools/blob/master/gopls/doc/commands.md#run-go-mod-tidy
local function mod_tidy()
  local go_mod_uri = find_go_mod_uri()

  local command_params = {
    command = 'gopls.tidy',
    arguments = {
      {
        URIs = { go_mod_uri },
      },
    },
  }
  local resp = vim.lsp.buf.execute_command(command_params)
  handle_error(resp)
end

local function find_tests()
  local bufnr = 0
  local custom_query = require('my-treesitter').get_query('go', 'tests')

  local parser = vim.treesitter.get_parser(bufnr, 'go')
  if not parser then
    return
  end

  local tree = parser:parse()[1]
  if not tree then
    return
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
local function scroll_to_end(bufnr)
  -- Ensure the buffer is valid and loaded
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.notify('Invalid or unloaded buffer: ' .. bufnr, vim.log.levels.ERROR)
    return
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  vim.api.nvim_win_set_cursor(0, { line_count, 0 })
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
  return bufnr, job_id
end

-- TODO fix find_... funcs and type hints and null checks
-- TODO fix deprecated API calls
-- TODO how can I run tests as verbose? or pass additional flags to the command?
-- TODO allow selection of a test with vim.ui or telescope? start simple. telescope is nice as it
-- could have a preview of the actual test on the right
-- TODO how to reuse most and make it work for java?
---@param test string
local function run_test(test)
  local buffer_name = 'go://tests'
  if not term_job_id then
    bufnr, term_job_id = open_terminal(buffer_name)
  else
    open_window(bufnr)
  end

  local command = 'go test ./...'
  if test then
    command = command .. ' -run ' .. test
  end
  command = command .. '\n'

  vim.fn.chansend(term_job_id, command)
end

return {
  add_import = add_import,
  add_dependency = add_dependency,
  mod_tidy = mod_tidy,
  run_test = run_test,
  find_tests = find_tests,
}

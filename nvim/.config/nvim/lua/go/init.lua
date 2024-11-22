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

-- TODO fix reusing the same buffer
-- TODO fix find_... funcs and type hints and null checks
-- TODO fix deprecated API calls
-- TODO create a main Go command with subcommands like Rest plugin
-- TODO can I autocomplete the Go test {tests}? this would allow me to adjust what is passed to go
-- test like using a regex or running a specific table test
-- TODO how can I run tests as verbose? or pass additional flags to the command?
-- TODO allow selection of a test with vim.ui or telescope? start simple. telescope is nice as it
-- could have a preview of the actual test on the right
-- TODO how to reuse most and make it work for java?
local function run_test(test)
  if not test then
    return
  end

  local BUFNAME = 'go://tests'
  -- Check if the buffer is already open
  local buf = vim.fn.bufnr(BUFNAME)

  if buf ~= -1 then -- If buffer exists
    -- Check if it's currently visible in a window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == buf then
        -- If open, close the window
        vim.api.nvim_win_close(win, true)
        return
      end
    end
  else
    -- Create a new buffer if it doesn't exist
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, BUFNAME)
  end

  local height = math.ceil(vim.o.lines * 0.4) -- 80% of screen height
  local width = math.ceil(vim.o.columns * 0.4) -- 80% of screen width
  local win = vim.api.nvim_open_win(buf, true, {
    split = 'below',
    style = 'minimal',
    width = width,
    height = height,
  })

  vim.api.nvim_win_set_buf(win, buf)

  vim.cmd('lcd ' .. vim.fn.fnameescape(find_go_mod_root()))

  -- Start a terminal in this buffer
  vim.cmd('terminal')

  -- Send the command to the terminal
  local term_job_id = vim.b.terminal_job_id
  vim.fn.chansend(term_job_id, 'go test ./... -run ' .. tests[1] .. ' \n')

  -- Automatically switch to insert mode for interaction
  vim.cmd('startinsert')
end

return {
  add_import = add_import,
  add_dependency = add_dependency,
  mod_tidy = mod_tidy,
  run_test = run_test,
  find_tests = find_tests,
}

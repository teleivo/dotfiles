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

local function find_go_mod_uri()
  local go_mod_file = vim.fn.findfile('go.mod', '.;')
  local go_mod_path = vim.fn.fnamemodify(go_mod_file, ':p')
  if go_mod_path == nil then
    vim.notify('Failed to find go.mod', vim.log.levels.ERROR)
    return
  end

  return vim.uri_from_fname(go_mod_path)
end

-- Add a dependency to the go.mod file. Uses gopls (LSP) command 'gopls.add_import'.
-- You can either pass the module path and version separately or pass them concatenated using @ like
-- so github.com/google/go-cmp@v0.6.0
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

return {
  add_import = add_import,
  add_dependency = add_dependency,
  mod_tidy = mod_tidy,
}

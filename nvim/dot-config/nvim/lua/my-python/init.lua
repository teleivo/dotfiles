local M = {}

--- Returns the executable name from the nearest .venv/bin found upwards from path. This way the
--- tool version pinned in the uv project is used. Falls back to name so it is looked up on the PATH.
--- @param name string The name of the executable.
--- @param path? string The directory to start searching from. Defaults to the cwd.
--- @return string
function M.venv_bin(name, path)
  local venv = vim.fs.find('.venv', { path = path, upward = true, type = 'directory' })[1]
  if venv then
    local bin = venv .. '/bin/' .. name
    if vim.fn.executable(bin) == 1 then
      return bin
    end
  end
  return name
end

--- Returns an LSP cmd function starting the executable found by venv_bin in the root_dir.
--- @param name string The name of the executable.
--- @param args string[] The arguments passed to the executable.
function M.lsp_cmd(name, args)
  return function(dispatchers, config)
    local cmd = vim.list_extend({ M.venv_bin(name, config.root_dir) }, args)
    return vim.lsp.rpc.start(cmd, dispatchers, { cwd = config.cmd_cwd, env = config.cmd_env })
  end
end

return M

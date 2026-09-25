-- https://docs.astral.sh/ruff/editors/settings/
return {
  cmd = require('my-python').lsp_cmd('ruff', { 'server' }),
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'ruff.toml',
    '.ruff.toml',
    '.git',
  },
  init_options = {
    settings = {
      configurationPreference = 'filesystemFirst',
    },
  },
  on_attach = function(client)
    -- ty provides type information on hover
    client.server_capabilities.hoverProvider = false
  end,
}

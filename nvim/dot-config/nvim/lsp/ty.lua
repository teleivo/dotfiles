-- https://docs.astral.sh/ty/reference/editor-settings/
return {
  cmd = require('my-python').lsp_cmd('ty', { 'server' }),
  filetypes = { 'python' },
  root_markers = {
    'ty.toml',
    'pyproject.toml',
    'uv.lock',
    '.git',
  },
}

return {
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  opts = {
    ensure_installed = {
      'codespell',
      'golangci-lint',
      'luacheck',
      'shellcheck',
      'stylua',
    },
    auto_update = true,
  },
}

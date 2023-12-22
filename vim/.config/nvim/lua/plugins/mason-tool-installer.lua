return {
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  opts = {
    ensure_installed = {
      'codespell',
      'delve',
      'golangci-lint',
      'luacheck',
      'shellcheck',
      'stylua',
    },
    auto_update = true,
  },
}

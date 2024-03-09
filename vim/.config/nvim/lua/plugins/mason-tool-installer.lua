return {
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  opts = {
    -- https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
    ensure_installed = {
      'bash-language-server',
      'codespell',
      'delve',
      'golangci-lint',
      'gopls',
      'json-lsp',
      'luacheck',
      'lua-language-server',
      'shellcheck',
      'stylua',
    },
    auto_update = true,
  },
}

return {
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  opts = {
    -- LSPs are installed by mason-lspconfig.nvim
    -- see ../plugins/lsp/init.lua
    ensure_installed = {
      'codespell',
      'delve',
      'golangci-lint',
      'google-java-format',
      'shellcheck',
      'sqlfmt',
      'stylua',
      -- 'luacheck', -- TODO fails to install
    },
    auto_update = true,
  },
}

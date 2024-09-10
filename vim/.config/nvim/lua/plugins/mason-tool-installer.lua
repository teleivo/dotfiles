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
      'stylua',
      -- 'luacheck', -- fails due to luarocks failing
    },
    auto_update = true,
  },
}

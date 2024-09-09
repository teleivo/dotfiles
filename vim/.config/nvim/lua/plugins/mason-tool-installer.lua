return {
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  opts = {
    -- LSPs are installed by mason-lspconfig.nvim
    -- see ../plugins/lsp/init.lua
    ensure_installed = {
      'codespell',
      'delve',
      'golangci-lint',
      -- 'luacheck', -- fails due to luarocks failing
      'shellcheck',
      'stylua',
    },
    auto_update = true,
  },
}

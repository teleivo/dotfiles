-- TODO finish this
-- nvim-cmp supports additional completion capabilities
-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- TODO 'folke/neodev.nvim',
-- TODO add mappings
return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      require('plugins.lsp.config')
    end,
  },
  {
    'williamboman/mason.nvim',
    config = true,
    build = ':MasonUpdate',
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    },
    opts = {
      automatic_installation = true,
      ensure_installed = {
        'lua_ls',
        'gopls',
      },
    },
  },
  --opts = {
  ---- capabilities = capabilities,
  --servers = {
  --lua_ls = {
  --settings = {
  --Lua = {
  --diagnostics = {
  --neededFileStatus = {
  --['codestyle-check'] = 'Any',
  --},
  --},
  --workspace = {
  --checkThirdParty = false,
  --},
  ---- Do not send telemetry data containing a randomized but unique identifier
  --telemetry = {
  --enable = false,
  --},
  --format = {
  --enable = true,
  --defaultConfig = {
  --indent_style = 'space',
  --indent_size = '2',
  --},
  --},
  --},
  --},
  --
  --},
  --}
  --}
  --},
  --{
  --
  --'williamboman/mason-lspconfig.nvim',
  --opts = {
  --ensure_installed = {
  --"lua_ls",
  --"stylua",
  --"shfmt",
  --"gopls",
  --},
  --}
  --}
  --}
}

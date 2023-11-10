-- TODO finish this
-- nvim-cmp supports additional completion capabilities
-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
--
-- TODO 'folke/neodev.nvim',
--
-- TODO add mappings in here instead of config?
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
        'jsonls',
      },
    },
  },
}

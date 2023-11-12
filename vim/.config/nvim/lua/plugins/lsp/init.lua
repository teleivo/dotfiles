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
        'yamlls',
        'jsonls',
        'bashls',
        'marksman',
      },
    },
  },
  {
    'folke/neodev.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
    },
    opts = {},
  },
}

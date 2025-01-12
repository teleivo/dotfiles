return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  lazy = false,
  cmd = {
    'AvanteAsk',
    'AvanteBuild',
    'AvanteChat',
    'AvanteEdit',
    'AvanteFocus',
    'AvanteRefresh',
    'AvanteSwitchProvider',
    'AvanteShowRepoMap',
    'AvanteToggle',
  },
  version = false,
  ---@module 'avante'
  ---@class avante.Config
  opts = {
    provider = 'copilot',
    auto_suggestions_provider = 'copilot',
    copilot = { model = 'claude-3.5-sonnet' },
    hints = {
      enabled = false,
    },
    windows = {
      width = 40, -- % based on available width
      sidebar_header = {
        enabled = false,
      },
    },
    file_selector = {
      provider = 'telescope',
    },
  },
  build = 'make',
  dependencies = {
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'saghen/blink.cmp',
    {
      'zbirenbaum/copilot.lua',
      opts = {
        suggestion = { enabled = false },
        panel = { enabled = false },
      },
    },
    'MeanderingProgrammer/render-markdown.nvim',
  },
}

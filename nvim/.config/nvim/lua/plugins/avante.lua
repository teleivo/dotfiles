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
  opts = {
    provider = 'copilot',
    auto_suggestions_provider = 'copilot',
    hints = {
      enabled = false,
    },
    windows = {
      width = 40, -- % based on available width
      sidebar_header = {
        enabled = false,
      },
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

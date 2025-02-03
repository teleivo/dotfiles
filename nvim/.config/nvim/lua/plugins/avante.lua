return {
  'yetone/avante.nvim',
  version = false,
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
  ---@module 'avante'
  ---@class avante.Config
  opts = {
    provider = 'copilot',
    auto_suggestions_provider = nil,
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
    {
      'MeanderingProgrammer/render-markdown.nvim',
      dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
      ft = { 'Avante' },
      ---@module 'render-markdown'
      ---@type render.md.UserConfig
      opts = {
        sign = { enabled = false },
        checkbox = {
          unchecked = {
            icon = '',
            highlight = '@comment.warning',
          },
          checked = {
            icon = '',
            highlight = '@comment.note',
          },
          custom = {
            todo = {
              raw = '[-]',
              rendered = '󰥔',
              highlight = '@comment.todo',
            },
          },
        },
        file_types = { 'Avante' },
        log_level = 'error',
      },
    },
  },
}

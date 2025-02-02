return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ft = { 'markdown', 'gitcommit', 'Avante', 'timesheet' },
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
      file_types = { 'markdown', 'gitcommit', 'Avante', 'timesheet' },
      log_level = 'error',
    },
  },
}

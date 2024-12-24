return {
  'stevearc/oil.nvim',
  config = function()
    local detail = false
    ---@module 'oil'
    ---@type oil.SetupOpts
    require('oil').setup({
      skip_confirm_for_simple_edits = true,
      keymaps = {
        ['gd'] = {
          desc = 'Toggle file detail view',
          callback = function()
            detail = not detail
            if detail then
              require('oil').set_columns({ 'icon', 'permissions', 'size', 'mtime' })
            else
              require('oil').set_columns({ 'icon' })
            end
          end,
        },
      },
    })
  end,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
}

return {
  'rest-nvim/rest.nvim',
  dependencies = { { 'nvim-lua/plenary.nvim' } },
  ft = 'http',
  config = function()
    local rest = require('rest-nvim')
    rest.setup({
      result_split_horizontal = true,
      stay_in_current_window_after_split = true,
    })

    vim.api.nvim_create_user_command('HttpRequest', function()
      rest.run()
    end, {
      nargs = 0,
    })

    vim.api.nvim_create_user_command('HttpRequestLast', function()
      rest.last()
    end, {
      nargs = 0,
    })

    vim.api.nvim_create_user_command('HttpPreview', function()
      rest.run(true)
    end, {
      nargs = 0,
    })
  end,
}

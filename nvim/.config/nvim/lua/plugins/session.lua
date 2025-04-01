local session_dir = '~/Documents/.vim-sessions/'

return {
  'tpope/vim-obsession',
  version = false, -- there are no releases
  cmd = {
    'Obsession',
  },
  -- mnemonic for keymap is 'edit' ('s' which would be great for session is already taken for snippets)
  keys = {
    {
      '<leader>es',
      function()
        local project_name = require('git').get_git_project_name()
        vim.api.nvim_feedkeys(':Obsession ' .. session_dir .. project_name, 'n', false)
      end,
      desc = 'Start recording a VIM session',
    },
    { '<leader>ep', ':Obsession<CR>', desc = 'Pause VIM session recording' },
    {
      '<leader>er',
      function()
        local project_name = require('git').get_git_project_name()
        vim.api.nvim_feedkeys(':source ' .. session_dir .. project_name, 'n', false)
      end,
      desc = 'Restore a VIM session',
    },
  },
  init = function()
    vim.g.session_dir = session_dir
  end,
}

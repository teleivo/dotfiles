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
      '<leader>fz', -- reads zession as fs is already taken for find symbols and fe for find errors
      function()
        local sessions = {}
        for name, type in vim.fs.dir(session_dir, { depth = 1 }) do
          if type == 'file' then
            table.insert(sessions, { name = name, path = session_dir .. name })
          end
        end

        vim.ui.select(sessions, {
          prompt = 'Select a VIM session to restore',
          format_item = function(item)
            return item.name
          end,
        }, function(choice)
          if not choice then
            return
          end

          vim.cmd.source(choice.path)
        end)
      end,
      desc = 'Find and restore a VIM session',
    },
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

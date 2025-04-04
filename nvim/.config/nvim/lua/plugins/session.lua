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
      '<leader>fz',
      function()
        local actions_state = require('telescope.actions.state')
        local actions = require('telescope.actions')

        local project_name = require('git').get_git_project_name()
        -- TODO disable multi select
        local opts = {
          prompt_title = 'Find and restore a VIM session',
          cwd = session_dir,
          default_text = project_name,
          attach_mappings = function(_, map)
            map({ 'i', 'n' }, '<CR>', function(prompt_bufnr)
              local selected_entry = actions_state.get_selected_entry()
              vim.api.nvim_feedkeys(':source ' .. session_dir .. selected_entry[1], 'n', false)
              actions.close(prompt_bufnr)
            end)

            -- do not trigger default mappings
            return false
          end,
        }
        require('telescope.builtin').find_files(opts)
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

local session_dir = '~/Documents/.vim-sessions/'
-- TODO merge/move this into ../../lua/git.lua; why do I need to use the filename in git.lua? is
-- that connected to a bug I see with the tabname at times?
local project_name = function()
  return vim.fs.basename(vim.fs.root(0, '.git') or '')
end

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
        vim.api.nvim_feedkeys(':Obsession ' .. session_dir .. project_name(), 'n', false)
      end,
      desc = 'Start recording a VIM session',
    },
    { '<leader>ep', ':Obsession<CR>', desc = 'Pause VIM session recording' },
    {
      '<leader>er',
      function()
        vim.api.nvim_feedkeys(':source ' .. session_dir .. project_name(), 'n', false)
      end,
      desc = 'Restore a VIM session',
    },
  },
  init = function()
    vim.g.session_dir = session_dir
  end,
}

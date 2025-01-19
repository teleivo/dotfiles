return {
  {
    'tpope/vim-fugitive',
    keys = {
      { '<leader>gs', ':Git status --short<CR>', desc = 'Git status' },
      { '<leader>gd', ':Git diff<CR>', desc = 'Git diff' },
      { '<leader>gds', ':Git diff --staged<CR>', desc = 'Git diff staged' },
      { '<leader>gap', ':Git add -p<CR>', desc = 'Git add patch' },
      { '<leader>gc', ':Git commit -v<CR>', desc = 'Git commit' },
      { '<leader>gp', ':Git push<CR>', desc = 'Git push' },
      { '<leader>gw', ':Gwrite<CR>', desc = 'Git write buffer and stage changes' },
      {
        '<leader>gg',
        function()
          local bufnr = nil
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local bufname = vim.api.nvim_buf_get_name(buf)
            if bufname:match('^fugitive://') then
              bufnr = buf
              break
            end
          end

          if not bufnr or not vim.api.nvim_buf_is_loaded(bufnr) then
            vim.cmd.Git()
            return
          end

          -- The fugitive buffer is kept when closing the window and thus reused on another
          -- invocation of :Git. I am deleting the buffer for simplicity.
          local winid = vim.fn.bufwinid(bufnr)
          vim.api.nvim_win_close(winid, true)
          vim.api.nvim_buf_delete(bufnr, { force = true })
        end,
        desc = 'Toggle git summary',
      },
    },
    cmd = {
      'G',
      'GBrowse',
      'GDelete',
      'GRemove',
      'Gcd',
      'Gclog',
      'Gdiffsplit',
      'Gedit',
      'Git',
      'Glcd',
      'Gllog',
      'Gmove',
      'Gread',
      'Grename',
      'Gsplit',
      'Gtabedit',
      'Gvdiffsplit',
      'Gvsplit',
      'Gwq',
      'Gwrite',
    },
    dependencies = {
      'tpope/vim-rhubarb',
    },
  },
}

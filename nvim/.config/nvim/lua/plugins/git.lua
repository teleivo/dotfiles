return {
  {
    'tpope/vim-fugitive',
    version = false, -- releases are too old
    keys = {
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
      { 'tpope/vim-rhubarb', version = false },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      preview_config = {
        border = 'rounded',
      },
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gitsigns.nav_hunk('next', { wrap = true, target = 'all' })
          end
        end, { desc = 'Jumpt to the next change or git hunk' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gitsigns.nav_hunk('prev', { wrap = true, target = 'all' })
          end
        end, { desc = 'Jumpt to the previous change or git hunk' })

        map('n', '<leader>ga', gitsigns.stage_hunk, { desc = 'Stage git hunk' })
        map('v', '<leader>ga', function()
          gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'Stage git hunk' })

        map('n', '<leader>gr', gitsigns.reset_hunk, { desc = 'Reset git hunk' })
        map('v', '<leader>gr', function()
          gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'Reset git hunk' })
        -- according to https://github.com/lewis6991/gitsigns.nvim/issues/1180 this is not
        -- deprecated
        map('n', '<leader>gu', gitsigns.undo_stage_hunk, { desc = 'Unstage staged git hunk' })

        map('n', '<leader>gdi', gitsigns.preview_hunk_inline, { desc = 'Show inline git diff' })
      end,
    },
  },
}

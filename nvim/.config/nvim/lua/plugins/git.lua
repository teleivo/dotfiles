return {
  {
    'tpope/vim-fugitive',
    keys = {
      -- TODO pick the best way for me to view diffs from fugitive or gitsigns so I only use one
      -- mapping. fugitive allows interacting with fugitive objects, is the same true for gitsigns?
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
  {
    'lewis6991/gitsigns.nvim',
    version = false, -- latest release is too old, pin when the next release
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
        end)

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gitsigns.nav_hunk('prev', { wrap = true, target = 'all' })
          end
        end)

        map('n', '<leader>gs', gitsigns.stage_hunk)
        map('v', '<leader>gs', function()
          gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end)

        map('n', '<leader>gr', gitsigns.reset_hunk)
        map('v', '<leader>gr', function()
          gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end)

        map('n', '<leader>gi', gitsigns.preview_hunk_inline)
      end,
    },
  },
}

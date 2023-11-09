return {
  {
    'tpope/vim-fugitive',
    keys = {
      { '<leader>gs', ':Git status --short<CR>' },
      { '<leader>gd', ':Git diff<CR>' },
      { '<leader>gds', ':Git diff --staged<CR>' },
      { '<leader>ga', ':Git add %:p<CR>' },
      { '<leader>gap', ':Git add -p<CR>' },
      { '<leader>gc', ':Git commit -v<CR>' },
      { '<leader>gp', ':Git push<CR>' },
    },
  },
}

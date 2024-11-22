return {
  {
    'tpope/vim-fugitive',
    keys = {
      { '<leader>gs', ':Git status --short<CR>', desc = 'Git status' },
      { '<leader>gd', ':Git diff<CR>', desc = 'Git diff' },
      { '<leader>gds', ':Git diff --staged<CR>', desc = 'Git diff staged' },
      { '<leader>ga', ':Git add %:p<CR>', desc = 'Git add current buffer' },
      { '<leader>gap', ':Git add -p<CR>', desc = 'Git add patch' },
      { '<leader>gc', ':Git commit -v<CR>', desc = 'Git commit' },
      { '<leader>gp', ':Git push<CR>', desc = 'Git push' },
    },
    cmd = {
      'G',
      'GBrowse',
      'Gcd',
      'Gclog',
      'Gdiffsplit',
      'Gedit',
      'Git',
      'Glcd',
      'Gllog',
      'Gread',
      'Gsplit',
      'Gtabedit',
      'Gvsplit',
      'Gwq',
      'Gwrite',
    },
    dependencies = {
      'tpope/vim-rhubarb',
    },
  },
}

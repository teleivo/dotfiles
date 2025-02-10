local width = 2
vim.opt_local.tabstop = width
vim.opt_local.shiftwidth = width
vim.opt_local.softtabstop = width
vim.opt_local.expandtab = true
vim.opt_local.textwidth = 0

vim.keymap.set(
  'n',
  '<leader>ro',
  ':Rest open<CR>',
  { buffer = true, desc = 'Open rest-nvim results' }
)
vim.keymap.set(
  'n',
  '<leader>rr',
  ':Rest run<CR>',
  { buffer = true, desc = 'Run HTTP request using rest-nvim' }
)
vim.keymap.set(
  'n',
  '<leader>rl',
  ':Rest last<CR>',
  { buffer = true, desc = 'Re-run last HTTP request using rest-nvim' }
)
vim.keymap.set(
  'n',
  '<leader>re',
  ':Rest env select<CR>',
  { buffer = true, desc = 'Select .env file for running HTTP request using rest-nvim' }
)

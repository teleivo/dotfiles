vim.opt_local.expandtab = true
-- do not break up long lines as this can mess up the HTTP parsing
vim.opt_local.textwidth = 0

vim.keymap.set(
  'n',
  '<leader>re',
  ':Rest env select<CR>',
  { buffer = true, desc = 'Select .env file for running HTTP request using rest-nvim' }
)
vim.keymap.set(
  'n',
  '<leader>ro',
  ':Rest open<CR>',
  { buffer = true, desc = 'Open rest-nvim results' }
)
-- Defining rn and rr for HTTP as well for consistency even though rest.nvim already runs nearest
-- request by default. Other filetype plugins use treesitter to determine the nearest runnable chunk
-- of code while rr will run the entire file.
vim.keymap.set(
  'n',
  '<leader>rn',
  ':Rest run<CR>',
  { buffer = true, desc = 'Run nearest HTTP request using rest-nvim' }
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

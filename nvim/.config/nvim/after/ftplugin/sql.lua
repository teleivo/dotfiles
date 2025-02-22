-- TODO implement nearest using treesitter
vim.keymap.set('n', '<leader>rn', ':%DB<CR>', { buffer = true, desc = 'Run nearest SQL statement' })
vim.keymap.set('n', '<leader>rr', ':%DB<CR>', { buffer = true, desc = 'Run current SQL file' })
vim.keymap.set(
  'v',
  '<leader>rr',
  ":'<,'>DB<CR>",
  { buffer = true, desc = 'Run visually selected SQL' }
)

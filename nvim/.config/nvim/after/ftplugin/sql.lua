vim.keymap.set('n', '<leader>dt', ':DBUIToggle<CR>', { buffer = true, desc = 'Toggle DBUI drawer' })
vim.keymap.set(
  'n',
  '<leader>dn',
  ':DBUIRenameBuffer<CR>',
  { buffer = true, desc = 'Rename DBUI buffer' }
)
vim.keymap.set(
  'n',
  '<leader>ds',
  '<Plug>(DBUI_SaveQuery)',
  { buffer = true, noremap = false, desc = 'Save SQL as DBUI query' }
)
vim.keymap.set(
  'n',
  '<leader>dp',
  '<Plug>(DBUI_EditBindParameters)',
  { buffer = true, noremap = false, desc = 'Bind parameters in SQL using vim-dadbod' }
)
vim.keymap.set(
  { 'n', 'v' },
  '<leader>dd',
  '<Plug>(DBUI_ExecuteQuery)',
  { buffer = true, noremap = false, desc = 'Execute SQL using vim-dadbod' }
)
-- TODO can I use :DBUIFindBuffer to set the DB for a buffer?
-- vim.keymap.set(
--   'n',
--   '<leader>re',
--   ':Rest env select<CR>',
--   { buffer = true, desc = 'Select .env file for running HTTP request using rest-nvim' }
-- )

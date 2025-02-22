local width = 2
vim.opt_local.tabstop = width
vim.opt_local.shiftwidth = width
vim.opt_local.softtabstop = width
vim.opt_local.expandtab = true

-- TODO what would running the nearest chunk of lua look like? does that even make sense?
-- TODO would I want to run the current line ':.lua<CR>'?

-- using ':%lua' instead of ':luafile' so it also works on a scratch buffer
vim.keymap.set('n', '<leader>rr', ':%lua<CR>', { buffer = true, desc = 'Run current Lua file' })
vim.keymap.set(
  'v',
  '<leader>rr',
  ':lua<CR>',
  { buffer = true, desc = 'Run visually selected Lua code' }
)

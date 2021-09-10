-- quickly save
vim.api.nvim_set_keymap('n', '<leader>w', ':w!<CR>', { noremap = true})
-- toggle showing whitespace
vim.api.nvim_set_keymap('n', '<leader>l', ':set list!<CR>', { noremap = true})
-- zoom a vim pane, <leader>= to re-balance
vim.api.nvim_set_keymap('n', '<leader>-', ':wincmd _<CR>:wincmd |<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>=', ':wincmd =<CR>', { noremap = true})
-- move a line
vim.api.nvim_set_keymap('n', '<A-j>', ':m .+1<CR>==', { noremap = true})
vim.api.nvim_set_keymap('n', '<A-k>', ':m .-2<CR>==', { noremap = true})
vim.api.nvim_set_keymap('i', '<A-j>', '<Esc>:m .+1<CR>==gi', { noremap = true})
vim.api.nvim_set_keymap('i', '<A-k>', '<Esc>:m .-2<CR>==gi', { noremap = true})
vim.api.nvim_set_keymap('v', '<A-j>', ':m \'>+1<CR>gv=gv', { noremap = true})
vim.api.nvim_set_keymap('v', '<A-k>', ':m \'<-2<CR>gv=gv', { noremap = true})

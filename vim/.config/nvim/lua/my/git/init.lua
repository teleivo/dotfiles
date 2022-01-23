require('gitsigns').setup({
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
})

vim.keymap.set('n', '<leader>gs', ':Git status --short<CR>')
vim.keymap.set('n', '<leader>gd', ':Git diff<CR>')
vim.keymap.set('n', '<leader>gds', ' :Git diff --staged<CR>')
vim.keymap.set('n', '<leader>ga', ':Git add %:p<CR>')
vim.keymap.set('n', '<leader>gap', ' :Git add -p<CR>')
vim.keymap.set('n', '<leader>gc', ':Git commit -v<CR>')
vim.keymap.set('n', '<leader>gp', ':Git push<CR>')

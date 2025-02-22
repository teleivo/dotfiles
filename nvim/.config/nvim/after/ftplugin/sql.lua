-- TODO implement nearest using treesitter
vim.keymap.set('n', '<leader>rn', function()
  local node = vim.treesitter.get_node()
  while node and node:type() ~= 'statement' do
    node = node:parent()
  end
  if node then
    local start_row, _, end_row, _ = node:range()
    vim.cmd(string.format('%d,%dDB', start_row + 1, end_row + 1))
  else
    vim.notify('No SQL statement found', vim.log.levels.WARN)
  end
end, { buffer = true, desc = 'Run nearest SQL statement' })
vim.keymap.set('n', '<leader>rr', ':%DB<CR>', { buffer = true, desc = 'Run current SQL file' })
vim.keymap.set(
  'v',
  '<leader>rr',
  ":'<,'>DB<CR>",
  { buffer = true, desc = 'Run visually selected SQL' }
)

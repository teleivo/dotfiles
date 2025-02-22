local ns = vim.api.nvim_create_namespace('my-sql')

-- TODO show currently connected DB in statusline in red or so
vim.keymap.set('n', '<leader>rn', function()
  local node = vim.treesitter.get_node()
  while node and node:type() ~= 'statement' do
    node = node:parent()
  end
  if node then
    local bufnr = 0
    local start_row, start_col, end_row, end_col = node:range()
    vim.hl.range(
      bufnr,
      ns,
      'Visual',
      { start_row, start_col }, -- looks as if hl.range is 0-indexed like TS
      { end_row, end_col },
      { inclusive = true }
    )

    vim.cmd(string.format('%d,%dDB', start_row + 1, end_row + 1))

    vim.defer_fn(function()
      pcall(vim.api.nvim_buf_clear_namespace, bufnr, ns, 0, -1)
    end, 300)
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

local ns = vim.api.nvim_create_namespace('my-sql')

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
-- TODO allow selecting the DB using re like I can with HTTP
vim.keymap.set('n', '<leader>re', function()
  local env_pattern = '.*%.env.*'
  local start = vim.api.nvim_buf_get_name(0)
  local git_dir = vim.fs.root(0, '.git')
  -- vim.fs.find stop is exclusive meaning the stop dir will not be searched
  local stop = vim.fs.dirname(git_dir)
  local env_files = vim.fs.find(function(name)
    return name:match(env_pattern)
  end, {
    limit = math.huge,
    type = 'file',
    path = start,
    stop = stop,
    upward = true,
  })
  vim.ui.select(env_files, {
    prompt = 'Select .env file to read DB connection from:',
  }, function(choice)
    Print(choice)
  end)
  -- parse .env for DB vars
  -- allow selecting DB if multiple or select directly
end, { buffer = true, desc = 'Select .env file for running SQL using vim-dadbod' })

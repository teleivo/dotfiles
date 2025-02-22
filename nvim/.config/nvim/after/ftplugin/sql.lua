local ns = vim.api.nvim_create_namespace('my-sql')

-- currently selected DB connection
local connection = {}

local select_db = function()
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

  if not env_files or vim.tbl_isempty(env_files) then
    vim.notify('No .env files found', vim.log.levels.WARN)
  end

  vim.ui.select(env_files, {
    prompt = 'Select .env file to read DB connection from:',
  }, function(selected_env_file)
    if not selected_env_file then
      vim.notify('No .env file selected', vim.log.levels.WARN)
      return
    end

    local env_content = vim.fn.readfile(selected_env_file)
    local urls = {}
    for _, line in ipairs(env_content) do
      if line:match('^DB_URL.*') then
        local key = line:match('^DB_URL_?([^=]*)=')
        local url = line:match('^DB_URL.*=(.+)')
        if key and url then
          table.insert(urls, {
            name = vim.trim(key),
            url = vim.trim(url),
          })
        end
      end
    end

    if vim.tbl_isempty(urls) then
      vim.notify('No DB_URL entries found in ' .. selected_env_file, vim.log.levels.WARN)
      return
    end

    vim.ui.select(urls, {
      prompt = 'Select database connection:',
      format_item = function(item)
        return item.name .. ' = ' .. item.url
      end,
    }, function(selected_connection)
      if not selected_connection then
        vim.notify('No DB connection selected', vim.log.levels.WARN)
        return
      end

      connection.file = selected_env_file
      connection.name = selected_connection.name
      connection.url = selected_connection.url

      Print(connection)

      -- default DB to run SQL against using vim-dadbod
      vim.g.db = connection.url
      -- set the global that is picked up by ../plugins/lualine.lua
      -- strip credentials
      vim.g.lualine_db = connection.name .. ' ' .. connection.url:match('@(.+)')
      vim.g.lualine_db_file = selected_env_file
    end)
  end)
end

vim.keymap.set('n', '<leader>rn', function()
  if vim.tbl_isempty(connection) then
    select_db()
  end
  Print(connection)
  if vim.tbl_isempty(connection) then
    vim.notify('No DB selected', vim.log.levels.WARN)
    return
  end

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
vim.keymap.set(
  'n',
  '<leader>re',
  select_db,
  { buffer = true, desc = 'Select .env file for running SQL using vim-dadbod' }
)

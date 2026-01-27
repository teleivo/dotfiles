vim.opt_local.expandtab = true

local ns = vim.api.nvim_create_namespace('my-sql')

-- currently selected DB connection
local connection = {}

-- pev2 watcher state
local pev2_job_id = nil
local pev2_watch_buf = nil
local pev2_url = nil

--- Get the JSON plan file path for a given SQL file
---@param sql_file string
---@return string
local function get_plan_file(sql_file)
  local dir = vim.fs.dirname(sql_file)
  local basename = vim.fs.basename(sql_file):gsub('%.sql$', '')
  return dir .. '/' .. basename .. '.json'
end

--- Stop the pev2 watcher
local function stop_pev2_watch()
  if pev2_job_id then
    vim.fn.jobstop(pev2_job_id)
    vim.notify('pev2 watcher stopped', vim.log.levels.INFO)
    pev2_job_id = nil
    pev2_watch_buf = nil
    pev2_url = nil
  end
end

--- Generate EXPLAIN plan for current buffer
local function generate_plan()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    vim.notify('Buffer must be saved to a file first', vim.log.levels.WARN)
    return
  end

  if vim.bo.modified then
    vim.notify('Buffer has unsaved changes, save first', vim.log.levels.WARN)
    return
  end

  if vim.fn.executable('psql') ~= 1 then
    vim.notify('psql not found in PATH', vim.log.levels.ERROR)
    return
  end

  local json_file = get_plan_file(file)
  local sql_content = table.concat(vim.fn.readfile(file), '\n')
  local explain_sql = 'explain (analyze, costs, verbose, buffers, format json)\n' .. sql_content

  vim.fn.jobstart({ 'psql', connection.url, '-XqAt', '-o', json_file, '-c', explain_sql }, {
    on_exit = function(_, exit_code, _)
      vim.schedule(function()
        if exit_code == 0 then
          vim.notify('Plan generated: ' .. vim.fs.basename(json_file), vim.log.levels.INFO)
        else
          vim.notify('Failed to generate plan (exit code ' .. exit_code .. ')', vim.log.levels.ERROR)
        end
      end)
    end,
    on_stderr = function(_, data, _)
      if data and #data > 0 then
        local msg = table.concat(data, '\n')
        if msg ~= '' then
          vim.schedule(function()
            vim.notify('psql: ' .. msg, vim.log.levels.WARN)
          end)
        end
      end
    end,
  })
end

--- Start pev2 watcher for a SQL file
---@param sql_file string
---@param json_file string
local function start_pev2_watch(sql_file, json_file)
  if vim.fn.executable('pev2') ~= 1 then
    vim.notify('pev2 not found in PATH', vim.log.levels.ERROR)
    return
  end

  if vim.fn.filereadable(json_file) ~= 1 then
    vim.notify('Plan file not found: ' .. json_file .. '. Generate plan first with <leader>rp', vim.log.levels.WARN)
    return
  end

  local bufnr = vim.fn.bufnr(sql_file)
  pev2_watch_buf = bufnr

  pev2_job_id = vim.fn.jobstart({ 'pev2', 'watch', '-query', sql_file, json_file }, {
    stdout_buffered = false,
    on_stdout = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          local url = line:match('(http://[%w%./:]+)')
          if url and not pev2_url then
            pev2_url = url
            vim.schedule(function()
              vim.ui.open(url)
              vim.notify('pev2 watching: ' .. vim.fs.basename(json_file), vim.log.levels.INFO)
            end)
          end
        end
      end
    end,
    on_stderr = function(_, data, _)
      if data and #data > 0 then
        local msg = table.concat(data, '\n')
        if msg ~= '' then
          vim.schedule(function()
            vim.notify('pev2: ' .. msg, vim.log.levels.WARN)
          end)
        end
      end
    end,
    on_exit = function(_, exit_code, _)
      vim.schedule(function()
        if exit_code ~= 0 and pev2_job_id then
          vim.notify('pev2 exited with code ' .. exit_code, vim.log.levels.WARN)
        end
        pev2_job_id = nil
        pev2_watch_buf = nil
        pev2_url = nil
      end)
    end,
  })
end

--- Toggle pev2 watcher for current buffer
local function toggle_pev2_watch()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    vim.notify('Buffer must be saved to a file first', vim.log.levels.WARN)
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()

  if pev2_job_id then
    if pev2_watch_buf == current_buf then
      stop_pev2_watch()
      return
    else
      stop_pev2_watch()
    end
  end

  local json_file = get_plan_file(file)
  start_pev2_watch(file, json_file)
end

---@generic T
---@param on_choice? fun(item: T|nil, idx: integer|nil)
local select_db = function(on_choice)
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
      vim.notify('No keys with prefix DB_URL_ found in ' .. selected_env_file, vim.log.levels.WARN)
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

      -- default DB to run SQL against using vim-dadbod
      vim.g.db = connection.url
      -- set the global that is picked up by ../plugins/lualine.lua
      -- strip credentials
      vim.g.lualine_db = ' ' .. connection.name .. ' ' .. connection.url:match('@(.+)')
      vim.g.lualine_db_file = selected_env_file

      -- notify postgres-lsp of the new connection for schema-aware features
      local clients = vim.lsp.get_clients({ name = "postgres_lsp", bufnr = 0 })
      for _, client in ipairs(clients) do
        client.notify("workspace/didChangeConfiguration", {
          settings = {
            db = {
              connectionString = connection.url,
            },
          },
        })
      end

      if on_choice then
        on_choice()
      end
    end)
  end)
end

-- Run visual SQL selection.
local run_selection = function()
  local selection =
    vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('v'), { type = vim.fn.mode() })
  local text = table.concat(selection, '\n')
  vim.cmd.DB({ args = { text } })
end

-- Run SQL statement or subquery nearest to current buffers cursor.
local run_nearest = function()
  local node = vim.treesitter.get_node()
  while node and (node:type() ~= 'statement' and node:type() ~= 'subquery') do
    node = node:parent()
  end

  if not node then
    vim.notify('No SQL statement found', vim.log.levels.WARN)
    return
  end

  local bufnr = 0
  local start_row, start_col, end_row, end_col = node:range()
  vim.hl.range(
    bufnr,
    ns,
    'Visual',
    { start_row, start_col }, -- looks as if hl.range is 0-indexed like TS
    { end_row, end_col },
    { inclusive = true, timeout = 300 }
  )

  pcall(vim.cmd.DB, { args = { vim.treesitter.get_node_text(node, 0) } })
end

vim.keymap.set('n', '<leader>rn', function()
  if vim.tbl_isempty(connection) then
    select_db(run_nearest)
    return
  end

  run_nearest()
end, { buffer = true, desc = 'Run nearest SQL statement' })

vim.keymap.set('n', '<leader>rr', function()
  if vim.tbl_isempty(connection) then
    select_db(function()
      vim.cmd('%DB')
    end)
    return
  end

  vim.cmd('%DB')
end, { buffer = true, desc = 'Run current SQL buffer' })

vim.keymap.set('v', '<leader>rr', function()
  if vim.tbl_isempty(connection) then
    select_db(run_selection)
    return
  end

  run_selection()
end, { buffer = true, desc = 'Run visually selected SQL' })

vim.keymap.set(
  'n',
  '<leader>re',
  select_db,
  { buffer = true, desc = 'Select .env file for running SQL using vim-dadbod' }
)

-- Run pgbench benchmark on current buffer
local run_benchmark = function(opts)
  opts = opts or {}
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    vim.notify('Buffer must be saved to a file first', vim.log.levels.WARN)
    return
  end

  local clients = opts.clients or 10
  local duration = opts.duration or 10
  local mode = opts.mode or 'all' -- 'bench', 'explain', 'all'

  local flag = mode == 'explain' and '-e' or mode == 'all' and '-a' or ''
  local cmd = string.format('DB_URL=%s pgbench-query %s -c %d -T %d %s', connection.url, flag, clients, duration, file)

  -- Run in terminal split
  vim.cmd('botright split | terminal ' .. cmd)
end

vim.keymap.set('n', '<leader>rb', function()
  if vim.tbl_isempty(connection) then
    select_db(run_benchmark)
    return
  end
  run_benchmark()
end, { buffer = true, desc = 'Run pgbench benchmark on buffer' })

vim.keymap.set('n', '<leader>rx', function()
  if vim.tbl_isempty(connection) then
    select_db(function()
      run_benchmark({ mode = 'explain' })
    end)
    return
  end
  run_benchmark({ mode = 'explain' })
end, { buffer = true, desc = 'Run EXPLAIN ANALYZE on buffer' })

vim.keymap.set('n', '<leader>rp', function()
  if vim.tbl_isempty(connection) then
    select_db(generate_plan)
    return
  end
  generate_plan()
end, { buffer = true, desc = 'Generate EXPLAIN plan JSON for pev2' })

vim.keymap.set('n', '<leader>rw', function()
  if vim.tbl_isempty(connection) then
    select_db(toggle_pev2_watch)
    return
  end
  toggle_pev2_watch()
end, { buffer = true, desc = 'Toggle pev2 watcher' })

-- Autocmds for pev2 cleanup
local pev2_augroup = vim.api.nvim_create_augroup('pev2_sql', { clear = true })

vim.api.nvim_create_autocmd('VimLeavePre', {
  group = pev2_augroup,
  callback = function()
    if pev2_job_id then
      vim.fn.jobstop(pev2_job_id)
    end
  end,
  desc = 'Stop pev2 watcher on Neovim exit',
})

vim.api.nvim_create_autocmd('BufDelete', {
  group = pev2_augroup,
  callback = function(args)
    if pev2_watch_buf == args.buf then
      stop_pev2_watch()
    end
  end,
  desc = 'Stop pev2 watcher when watched buffer is deleted',
})

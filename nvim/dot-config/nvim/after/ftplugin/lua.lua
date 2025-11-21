vim.opt_local.expandtab = true

-- Run a chunk of lua code and capture its calls to print() and return values in a scratch buffer in
-- a preview window.
--
-- Using this instead of ':lua', ':=' or ':luafile' as these show only the calls to print() in the
-- :messages which is hard to interact with. This allows me to interact with the output like with
-- any other buffer text.
--- @param chunk string[] Array of lines, or empty array for unloaded buffer.
local run = function(chunk)
  local chunk_str = table.concat(chunk, '\n')

  local fn, err = loadstring(chunk_str)
  if err then
    vim.notify("ftplugin/lua: Error loading Lua chunk '" .. err .. "'", vim.log.levels.ERROR)
    return
  end

  -- capture calls to `print()`
  local print_calls = {}
  local original_print = _G.print
  _G.print = function(...)
    table.insert(print_calls, { ... })
  end

  -- execute the function and capture returns
  ---@diagnostic disable-next-line: param-type-mismatch
  local result_pcall = { pcall(fn) }

  -- restore original print function
  _G.print = original_print

  local ok = result_pcall[1]
  if not ok then
    vim.notify(
      "ftplugin/lua: Error executing Lua chunk '" .. result_pcall[2] .. "'",
      vim.log.levels.ERROR
    )
    return
  end

  local lines = {}

  -- add print args to results if any
  if not vim.tbl_isempty(print_calls) then
    table.insert(lines, '-- Calls to print():')
    for i, print_call in ipairs(print_calls) do
      for j, arg in ipairs(print_call) do
        table.insert(lines, '-- call ' .. i .. ', arg ' .. j .. ':')
        table.insert(lines, tostring(arg))
      end
      if i < #print_calls then
        table.insert(lines, '')
      end
    end
  end

  -- add return values if any
  if #result_pcall > 1 then
    if not vim.tbl_isempty(print_calls) then
      table.insert(lines, '')
    end

    table.insert(lines, '-- Return values:')
    for i = 2, #result_pcall do
      table.insert(lines, '-- value ' .. i - 1 .. ':')
      table.insert(lines, vim.inspect(result_pcall[i]))
    end
  end

  if vim.tbl_isempty(lines) then
    vim.notify(
      'Lua chunk ran successfully without printing or returning a result',
      vim.log.levels.INFO
    )
    return
  end

  lines = vim
    .iter(lines)
    :map(function(v)
      return vim.split(v, '\n')
    end)
    :flatten()
    :totable()

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  require('my-neovim').open_preview_window(bufnr, nil, false, {
    height = 15,
  })
end

local visual_start
local visual_end

vim.keymap.set('n', '<leader>rr', function()
  local chunk = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  run(chunk)
end, { buffer = true, desc = 'Run current Lua file' })

vim.keymap.set('v', '<leader>rr', function()
  visual_start = vim.fn.getpos('.')
  visual_end = vim.fn.getpos('v')
  local chunk = vim.fn.getregion(visual_start, visual_end, { type = vim.fn.mode() })
  run(chunk)
end, { buffer = true, desc = 'Run visually selected Lua chunk' })

-- This runs the last visually selected Lua chunk. I could also capture the last parsed chunk. This
-- approach is a bit more flexible as it allows me to change the chunk and quickly rerun it as long
-- as the region does not change.
vim.keymap.set('n', '<leader>rl', function()
  if not visual_start or not visual_end then
    vim.notify('ftplugin/lua: No previous visual selection of a Lua chunk', vim.log.levels.INFO)
    return
  end

  local ok, chunk = pcall(function()
    return vim.fn.getregion(visual_start, visual_end, { type = vim.fn.visualmode() })
  end)
  if not ok then
    vim.notify(
      'ftplugin/lua: Previous visually selected region is no longer valid',
      vim.log.levels.ERROR
    )
    return
  end
  if not chunk then
    vim.notify('ftplugin/lua: No Lua chunk selected', vim.log.levels.ERROR)
    return
  end

  run(chunk)
end, { buffer = true, desc = 'Re-run last visually selected Lua chunk' })

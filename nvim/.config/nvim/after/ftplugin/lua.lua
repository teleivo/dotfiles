local width = 2
vim.opt_local.tabstop = width
vim.opt_local.shiftwidth = width
vim.opt_local.softtabstop = width
vim.opt_local.expandtab = true

-- TODO do I want to rerun the last chunk? I have it in a function already?
-- or rerun last range is more what I want. if its range take care of that range not existing
-- anymore
local run = function(code)
  code = table.concat(code, '\n')

  local fn, err = loadstring(code)
  if err then
    vim.notify("Error loading Lua chunk '" .. err .. "'", vim.log.levels.ERROR)
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
    vim.notify("Error executing Lua chunk '" .. result_pcall[2] .. "'", vim.log.levels.ERROR)
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

-- using ':%lua' instead of ':luafile' so it also works on a scratch buffer
vim.keymap.set('n', '<leader>rr', function()
  local code = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  run(code)
end, { buffer = true, desc = 'Run current Lua file' })
vim.keymap.set('v', '<leader>rr', function()
  local code = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('v'), { type = vim.fn.mode() })
  run(code)
end, { buffer = true, desc = 'Run visually selected Lua code' })

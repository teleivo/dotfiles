local width = 2
vim.opt_local.tabstop = width
vim.opt_local.shiftwidth = width
vim.opt_local.softtabstop = width
vim.opt_local.expandtab = true

-- TODO handle multiple return values
-- TODO do I want to rerun the last chunk? I have it in a function already?
-- or rerun last range is more what I want
local run = function(code)
  code = table.concat(code, '\n')

  local fn, err = loadstring(code)
  if err then
    vim.notify("Error loading Lua chunk '" .. err .. "'", vim.log.levels.ERROR)
    return
  end

  ---@diagnostic disable-next-line: param-type-mismatch
  local result_pcall = { pcall(fn) }
  local ok = result_pcall[1]

  if not ok then
    vim.notify("Error executing Lua chunk '" .. result_pcall[2] .. "'", vim.log.levels.ERROR)
    return
  end

  -- extract return values of fn (discard the ok, ... = pcall(fn()))
  local result
  if #result_pcall > 0 then
    result = vim.list_slice(result_pcall, 2)
  end

  local result_str
  if #result > 0 then
    result_str = vim.split(vim.inspect(result), '\n')
  else
    vim.notify('Lua chunk ran successfully without returning a result', vim.log.levels.INFO)
    return
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result_str)
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

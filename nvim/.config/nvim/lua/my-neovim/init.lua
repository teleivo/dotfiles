local M = {}

---@param bufnr integer
local function auto_scroll_to_end(bufnr)
  -- Ensure the buffer is valid and loaded
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.notify('Invalid or unloaded buffer: ' .. bufnr, vim.log.levels.ERROR)
    return
  end

  -- Set an autocmd to track updates to the buffer
  vim.api.nvim_create_autocmd({ 'BufWritePost', 'TextChanged', 'TextChangedI' }, {
    buffer = bufnr,
    callback = function()
      if vim.api.nvim_get_current_buf() == bufnr then
        -- Scroll to the end if the buffer is active in the current window
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        vim.api.nvim_win_set_cursor(0, { line_count, 0 })
      end
    end,
    desc = 'Automatically scroll to end of buffer',
  })
end

---@param bufnr integer
---@return boolean
local function is_buffer_visible(bufnr)
  if vim.fn.bufwinid(bufnr) ~= -1 then
    return true
  end

  return false
end

---@param bufnr integer The buffer to open in the window.
---@param dir string? The directory used to set the window local directory. The window local
---directory is not set if nil.
local function open_window(bufnr, dir)
  if is_buffer_visible(bufnr) then
    return
  end

  local width = math.ceil(vim.o.columns * 0.4) -- 40% of screen width
  local win = vim.api.nvim_open_win(bufnr, true, {
    split = 'left',
    style = 'minimal',
    width = width,
  })
  vim.api.nvim_win_set_buf(win, bufnr)
  if dir then
    vim.cmd('lcd ' .. vim.fn.fnameescape(dir))
  end
end

local bufnr
local term_job_id

---Open terminal ensures one project wide terminal is open in a window.
---@param dir string The directory used to set the window local directory.
---@return integer job_id The job id of the terminal to use with vim.fn.chansend.
---@return integer bufnr The buffer number in which the terminal is displayed.
function M.open_terminal(dir)
  -- assuming that if the buffer is valid the terminal is still running in it
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    open_window(bufnr, dir)
    return term_job_id, bufnr
  end

  bufnr = vim.api.nvim_create_buf(true, true)
  open_window(bufnr, dir)

  vim.api.nvim_set_current_buf(bufnr)
  term_job_id = vim.fn.jobstart(vim.o.shell, {
    term = true,
    on_exit = function(_, exit_code, _)
      vim.notify('Terminal exited with code: ' .. exit_code, vim.log.levels.WARN)
      term_job_id = nil
    end,
  })
  vim.api.nvim_buf_set_name(bufnr, 'my-neovim#terminal')
  auto_scroll_to_end(bufnr)

  return term_job_id, bufnr
end

---Opens the terminal buffer in a window if closed or closes it if open.
function M.toggle_terminal()
  -- assuming that if the buffer is valid the terminal is still running in it
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    vim.notify('my-neovim: there is no terminal buffer', vim.log.levels.INFO)
    return
  end

  if not is_buffer_visible(bufnr) then
    open_window(bufnr)
    return
  end

  local winid = vim.fn.bufwinid(bufnr)
  vim.api.nvim_win_close(winid, true)
end

return M

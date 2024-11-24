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
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      return true
    end
  end

  return false
end

---@param bufnr integer The buffer to open in the window.
---@param dir string The directory used to set the window local directory.
local function open_window(bufnr, dir)
  if is_buffer_visible(bufnr) then
    return
  end

  local height = math.ceil(vim.o.lines * 0.35) -- 40% of screen height
  local width = math.ceil(vim.o.columns * 0.4) -- 40% of screen width
  local win = vim.api.nvim_open_win(bufnr, true, {
    split = 'below',
    style = 'minimal',
    width = width,
    height = height,
  })
  vim.api.nvim_win_set_buf(win, bufnr)
  vim.cmd('lcd ' .. vim.fn.fnameescape(dir))
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
  term_job_id = vim.fn.termopen(vim.o.shell, {
    on_exit = function(_, exit_code, _)
      vim.notify('Terminal exited with code: ' .. exit_code, vim.log.levels.ERROR)
      term_job_id = nil
    end,
  })
  vim.api.nvim_buf_set_name(bufnr, 'project terminal')
  auto_scroll_to_end(bufnr)

  return term_job_id, bufnr
end

return M

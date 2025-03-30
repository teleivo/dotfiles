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

-- Keep track of preview windows per tab page number as only one preview window per tab page is
-- allowed
local preview_windows = {}

---@param bufnr integer The buffer to open in the window.
---@param dir string? The directory used to set the window local directory of the preview window.
---The window local directory is not set if nil.
---@param enter boolean? Enter the preview window (make it the current window)
---@param config? vim.api.keyset.win_config Map defining the window configuration.
function M.open_preview_window(bufnr, dir, enter, config)
  enter = enter or false
  config = config or {}
  config = vim.tbl_deep_extend('keep', config, {
    split = 'below',
    style = 'minimal',
    height = 20,
  })
  local tabnr = vim.api.nvim_get_current_tabpage()
  local win = preview_windows[tabnr]

  if not win or not vim.api.nvim_win_is_valid(win) then
    win = vim.api.nvim_open_win(bufnr, enter, config)
    vim.wo[win].previewwindow = true
    preview_windows[tabnr] = win
  end

  vim.api.nvim_win_set_buf(win, bufnr)
  if dir then
    vim.cmd('lcd ' .. vim.fn.fnameescape(dir))
  end

  return win
end

---@param bufnr integer The buffer to open in the window.
---@param dir string? The directory used to set the window local directory. The window local
---directory is not set if nil.
local function open_window(bufnr, dir)
  if is_buffer_visible(bufnr) then
    return
  end

  local win = vim.api.nvim_open_win(bufnr, false, {
    split = 'below',
    style = 'minimal',
    height = 20,
  })
  vim.api.nvim_win_set_buf(win, bufnr)
  if dir then
    vim.cmd('lcd ' .. vim.fn.fnameescape(dir))
  end
end

local term_bufnr
local term_job_id

---@alias Terminal.keymaps Terminal.keymap[]

---@class Terminal.keymap
---@field [1] string Mode for the keymap
---@field [2] string Left-hand side (lhs) of the mapping
---@field [3] string|function Right-hand side (rhs) of the mapping
---@field [4] table? Optional keymap options

---Open terminal ensures one project wide terminal is open in a window.
---@param dir string The directory used to set the window local directory.
---@param keymaps Terminal.keymaps? Optional keymaps added to the terminal buffer.
---@return integer job_id The job id of the terminal to use with vim.fn.chansend.
---@return integer bufnr The buffer number in which the terminal is displayed.
function M.open_terminal(dir, keymaps)
  local cur_win = vim.api.nvim_get_current_win()
  local cur_bufnr = vim.api.nvim_get_current_buf()

  -- assuming that if the buffer is valid the terminal is still running in it
  if term_bufnr and vim.api.nvim_buf_is_valid(term_bufnr) then
    M.open_preview_window(term_bufnr, dir)
    return term_job_id, term_bufnr
  end

  term_bufnr = vim.api.nvim_create_buf(false, true)
  -- TODO add keymap like g? that shows a floating help with the keymaps like :Oil
  if keymaps then
    for _, keymap in ipairs(keymaps) do
      vim.keymap.set(
        keymap[1],
        keymap[2],
        keymap[3],
        vim.tbl_extend('force', keymap[4], { noremap = true, silent = true, buffer = term_bufnr })
      )
    end
  end

  -- using vim.fn.jobstart so I can interact with the terminal in a better way than using :term
  -- unfortunately term=true only works with the current buffer so I need to set the window/buffer
  -- otherwise the current buffer I am in will be taken over by the terminal
  M.open_preview_window(term_bufnr, dir, true)
  term_job_id = vim.fn.jobstart(vim.o.shell, {
    term = true,
    on_exit = function(_, exit_code, _)
      vim.notify('Terminal exited with code: ' .. exit_code, vim.log.levels.WARN)
      term_job_id = nil
    end,
  })
  auto_scroll_to_end(term_bufnr)

  -- restore window and buffer
  vim.api.nvim_set_current_win(cur_win)
  vim.api.nvim_set_current_buf(cur_bufnr)

  return term_job_id, term_bufnr
end

---Opens the terminal buffer in a window if closed or closes it if open.
function M.toggle_terminal()
  -- assuming that if the buffer is valid the terminal is still running in it
  if not term_bufnr or not vim.api.nvim_buf_is_valid(term_bufnr) then
    vim.notify('my-neovim: there is no terminal buffer', vim.log.levels.INFO)
    return
  end

  if not is_buffer_visible(term_bufnr) then
    open_window(term_bufnr)
    return
  end

  local winid = vim.fn.bufwinid(term_bufnr)
  vim.api.nvim_win_close(winid, true)
end

return M

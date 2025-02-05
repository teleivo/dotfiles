local M = {}
local ns = vim.api.nvim_create_namespace('typing_practice')
local active = false
local original_text = {}
local current_line = 0
local current_col = 0
local prev_blink_state = nil
local autocmd_id = nil

function M.setup()
  vim.api.nvim_create_user_command('TypingPractice', M.start, {})
  vim.api.nvim_create_user_command('TypingPracticeStop', M.stop, {})
end

function M.start()
  if active then
    print('Typing practice already active!')
    return
  end

  active = true
  current_line = 1
  current_col = 0

  -- Store original buffer content
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  original_text = lines

  autocmd_id = vim.api.nvim_create_autocmd({ 'InsertCharPre' }, {
    callback = function()
      if not active then
        return
      end
      local char = vim.v.char
      M.check_char(char)
      -- Prevent actual character insertion
      vim.v.char = ''
    end,
  })

  -- Clear existing marks
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

  -- Map tab key to prevent tab insertion
  vim.keymap.set('i', '<Tab>', function()
    if not active then
      return '<Tab>'
    end
    -- Move cursor to next tabstop
    local new_col = current_col + vim.bo.tabstop
    local current_line_text = original_text[current_line]
    if current_line_text and new_col <= #current_line_text then
      current_col = new_col
      vim.api.nvim_win_set_cursor(0, { current_line, current_col })
    end
    return ''
  end, { expr = true, buffer = true })

  -- Map enter key to prevent newline insertion
  vim.keymap.set('i', '<CR>', function()
    if not active then
      return '<CR>'
    end
    local current_line_text = original_text[current_line]
    if current_line_text and current_col >= #current_line_text then
      current_line = current_line + 1
      current_col = 0
      -- Move cursor to next line and schedule cursor update
      vim.schedule(function()
        vim.api.nvim_win_set_cursor(0, { current_line, 0 })
      end)
    end
    return ''
  end, { expr = true, buffer = true })

  -- Disable blink.cmp
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    prev_blink_state = blink.enabled
    blink.enabled = false
  end
  require('nvim-autopairs').disable()

  vim.cmd('startinsert')
  print('Typing practice started! Press <ESC> and run :TypingPracticeStop to end')
end

function M.check_char(char)
  local current_line_text = original_text[current_line]
  if not current_line_text then
    return
  end

  -- Handle enter key
  if char == '\r' or char == '\n' then
    if current_col >= #current_line_text then
      current_line = current_line + 1
      current_col = 0
    end
    return
  end

  -- Don't proceed if we're at the end of a line but haven't pressed enter
  if current_col >= #current_line_text then
    return
  end

  local expected_char = current_line_text:sub(current_col + 1, current_col + 1)

  -- Always show typed character, with color based on correctness
  vim.api.nvim_buf_set_extmark(0, ns, current_line - 1, current_col, {
    virt_text = { { char, char == expected_char and 'DiffAdd' or 'ErrorMsg' } },
    virt_text_pos = 'overlay',
    hl_mode = 'combine',
    hl_group = char ~= expected_char and 'Error' or nil,
    priority = 100,
  })

  current_col = current_col + 1
  -- Update cursor position
  vim.api.nvim_win_set_cursor(0, { current_line, current_col })
end

function M.stop()
  if not active then
    print('Typing practice not active!')
    return
  end

  active = false
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

  -- Clean up autocmd
  if autocmd_id then
    vim.api.nvim_del_autocmd(autocmd_id)
    autocmd_id = nil
  end

  -- Remove key mappings
  pcall(vim.keymap.del, 'i', '<CR>', { buffer = true })
  pcall(vim.keymap.del, 'i', '<Tab>', { buffer = true })

  -- Restore blink.cmp state

  if prev_blink_state ~= nil then
    local ok, blink = pcall(require, 'blink.cmp')
    if ok then
      blink.enabled = prev_blink_state
    end
  end
  require('nvim-autopairs').enable()

  vim.cmd('stopinsert')
  print('Typing practice stopped!')
end

M.setup()

return M

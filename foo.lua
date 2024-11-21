-- TODO allow selection of a test with vim.ui or telescope? start simple. telescope is nice as it
-- could have a preview of the actual test on the right
local bufnr = 7

local BUFNAME = 'go://tests'
-- TODO fix reusing the same buffer
-- Check if the buffer is already open
local buf = vim.fn.bufnr(BUFNAME)

if buf ~= -1 then -- If buffer exists
  -- Check if it's currently visible in a window
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      -- If open, close the window
      vim.api.nvim_win_close(win, true)
      return
    end
  end
else
  -- Create a new buffer if it doesn't exist
  buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, BUFNAME)
end

local height = math.ceil(vim.o.lines * 0.4) -- 80% of screen height
local width = math.ceil(vim.o.columns * 0.4) -- 80% of screen width
local win = vim.api.nvim_open_win(buf, true, {
  split = 'below',
  style = 'minimal',
  width = width,
  height = height,
})

vim.api.nvim_win_set_buf(win, buf)

-- TODO fix this to find the go.mod root, make this a function in my go module
-- Get the directory of the current file
-- use find_go_mod_uri in ./vim/.config/nvim/lua/go/init.lua
--
-- local current_file_dir = vim.fn.expand('%:p:h')
local current_file_dir = vim.fn.expand('#' .. bufnr .. ':p:h')
Print(current_file_dir)
-- Find the project root using .git as the marker
local project_root = vim.fn.finddir('.git', current_file_dir .. ';')
-- If .git is found, get its parent directory
if project_root ~= '' then
  project_root = vim.fn.fnamemodify(project_root, ':h')
else
  -- If no .git is found, use the current file's directory as fallback
  project_root = current_file_dir
end
vim.cmd('lcd ' .. vim.fn.fnameescape(project_root))

-- Start a terminal in this buffer
vim.cmd('terminal')

-- Send the command to the terminal
local term_job_id = vim.b.terminal_job_id
vim.fn.chansend(term_job_id, 'go test ./... -run ' .. tests[1] .. ' \n')

-- Automatically switch to insert mode for interaction
vim.cmd('startinsert')

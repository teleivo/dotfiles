local toggle_quickfixlist = function(location)
  local window_type = 'quickfix'
  if location then
    window_type = 'loclist'
  end

  local fns = {
    loclist = {
      functions = {
        getlist = function(...)
          return vim.fn.getloclist(0, ...)
        end, -- current location list
      },
      commands = {
        open = 'lopen',
        close = 'lclose',
      },
    },
    quickfix = {
      functions = {
        getlist = vim.fn.getqflist,
      },
      commands = {
        open = 'copen',
        close = 'cclose',
      },
    },
  }

  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win[window_type] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd(fns[window_type].commands.close)
    return
  end
  if vim.tbl_isempty(fns[window_type].functions.getlist()) then
    vim.api.nvim_echo({ { window_type .. ' is empty', 'ErrorMsg' } }, false, {})
    return
  end
  vim.cmd(fns[window_type].commands.open)
end

-- quickfix/location list (open/close, navigate)
vim.keymap.set('n', '<C-q>', toggle_quickfixlist)
vim.keymap.set('n', '<leader>q', toggle_quickfixlist)
vim.keymap.set('n', '[q', ':cprev<CR>zz')
vim.keymap.set('n', '[l', ':lprev<CR>zz')
vim.keymap.set('n', ']q', ':cnext<CR>zz')
vim.keymap.set('n', ']l', ':lnext<CR>zz')
-- stay on home row for returning to normal mode
vim.keymap.set('i', 'jj', '<ESC>')
-- quickly save
vim.keymap.set('n', '<leader>w', ':w!<CR>')
-- toggle showing whitespace
vim.keymap.set('n', '<leader>l', ':set list!<CR>')
-- zoom a vim pane, <leader>= to re-balance
vim.keymap.set('n', '<leader>-', ':wincmd _<CR>:wincmd |<CR>')
vim.keymap.set('n', '<leader>=', ':wincmd =<CR>')
-- move a line
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==')
vim.keymap.set('i', '<A-j>', '<Esc>:m .+1<CR>==gi')
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==')
vim.keymap.set('i', '<A-k>', '<Esc>:m .-2<CR>==gi')
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv")
-- search
-- center on search results when paging through
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- remap space as leader key
vim.keymap.set({ 'n', 'v' }, '<space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

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

-- Discern <tab> and <C-i> by configuring alacritty to send different chars and neovim to not map it
-- like <tab>
-- https://github.com/neovim/neovim/issues/14090#issuecomment-1113090354
vim.keymap.set('n', '<C-i>', '<C-i>')

-- quickfix/location list (open/close, navigate)
vim.keymap.set('n', '<C-q>', toggle_quickfixlist, { desc = 'Toggle the quickfix list' })
vim.keymap.set('n', '<leader>q', toggle_quickfixlist, { desc = 'Toggle the quickfix list' })

vim.keymap.set(
  'n',
  '[q',
  ':cprevious<CR>zz',
  { desc = 'Display the previous item in the quickfix list' }
)
vim.keymap.set('n', ']q', ':cnext<CR>zz', { desc = 'Display the next item in the quickfix list' })
vim.keymap.set('n', '[Q', ':cfirst<CR>zz', { desc = 'Display the first item in the quickfix list' })
vim.keymap.set('n', ']Q', ':clast<CR>zz', { desc = 'Display the last item in the quickfix list' })

vim.keymap.set(
  'n',
  '[l',
  ':lprevious<CR>zz',
  { desc = 'Display the previous item in the location list' }
)
vim.keymap.set('n', ']l', ':lnext<CR>zz', { desc = 'Display the next item in the location list' })
vim.keymap.set('n', '[L', ':lfirst<CR>zz', { desc = 'Display the first item in the location list' })
vim.keymap.set('n', ']L', ':llast<CR>zz', { desc = 'Display the last item in the location list' })

vim.keymap.set(
  'n',
  '[b',
  ':bprevious<CR>zz',
  { desc = 'Display the previous buffer in the buffer list' }
)
vim.keymap.set('n', ']b', ':bnext<CR>zz', { desc = 'Display the next buffer in the buffer list' })
vim.keymap.set('n', '[B', ':bfirst<CR>zz', { desc = 'Display the first buffer in the buffer list' })
vim.keymap.set('n', ']B', ':blast<CR>zz', { desc = 'Display the last buffer in the buffer list' })

-- diagnostics
vim.keymap.set('n', '<leader>e', function()
  vim.diagnostic.open_float()
end, { desc = 'Open diagnostics' })

-- quickly save
vim.keymap.set('n', '<leader>w', ':w!<CR>', { desc = 'Save buffer' })
-- toggle showing whitespace
vim.keymap.set('n', '<leader>l', ':set list!<CR>', { desc = 'Toggle showing whitespace' })
-- zoom a vim pane, <leader>= to re-balance
vim.keymap.set(
  'n',
  '<leader>-',
  ':wincmd _<CR>:wincmd |<CR>',
  { desc = 'Zoom in on current window hiding other splits' }
)
vim.keymap.set(
  'n',
  '<leader>=',
  ':wincmd =<CR>',
  { desc = 'Exit zoom of current window and re-balance splits' }
)
-- move a line
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
vim.keymap.set('i', '<A-j>', '<Esc>:m .+1<CR>==gi', { desc = 'Move line down' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move line down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
vim.keymap.set('i', '<A-k>', '<Esc>:m .-2<CR>==gi', { desc = 'Move line up' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move line up' })
-- search
-- center on search results when paging through
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Go to next search result (centering page on it)' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Go to previous search result (centering page on it)' })
-- navigate on the cmdline more like in a shell
vim.keymap.set('c', '<C-A>', '<Home>', { desc = 'Navigate to the start of the command' })
vim.keymap.set('c', '<C-B>', '<Left>', { desc = 'Navigate one character back in the command' })
vim.keymap.set('c', '<C-F>', '<Right>', { desc = 'Navigate one character forward in the command' })

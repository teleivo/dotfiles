-- TODO make it local once https://github.com/neovim/neovim/issues/14976
function my_toggle_quickfix(location)
  local window_type = 'quickfix'
  if location then
    window_type = 'loclist'
  end

  local fns = {
    loclist = {
      functions = {
        getlist = function(...) return vim.fn.getloclist(0, ...) end, -- current location list
      },
      commands = {
        open = 'lopen',
        close = 'lclose',
      }
    },
    quickfix = {
      functions = {
        getlist = vim.fn.getqflist,
      },
      commands = {
        open = 'copen',
        close = 'cclose',
      }
    }
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
    vim.api.nvim_echo({{ window_type .. ' is empty', 'ErrorMsg' }}, false, {})
    return
  end
  vim.cmd(fns[window_type].commands.open)
end

-- quickfix/location list (open/close, navigate)
vim.api.nvim_set_keymap('n', '<C-q>', ':lua my_toggle_quickfix()<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>q', ':lua my_toggle_quickfix(true)<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<C-j>', ':cprev<CR>zz', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>j', ':lprev<CR>zz', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-k>', ':cnext<CR>zz', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>k', ':lnext<CR>zz', { noremap = true })
-- stay on home row for returning to normal mode
vim.api.nvim_set_keymap('i', 'jj', '<ESC>', { noremap = true})
-- quickly save
vim.api.nvim_set_keymap('n', '<leader>w', ':w!<CR>', { noremap = true})
-- toggle showing whitespace
vim.api.nvim_set_keymap('n', '<leader>l', ':set list!<CR>', { noremap = true})
-- zoom a vim pane, <leader>= to re-balance
vim.api.nvim_set_keymap('n', '<leader>-', ':wincmd _<CR>:wincmd |<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>=', ':wincmd =<CR>', { noremap = true})
-- move a line
vim.api.nvim_set_keymap('n', '<A-j>', ':m .+1<CR>==', { noremap = true})
vim.api.nvim_set_keymap('n', '<A-k>', ':m .-2<CR>==', { noremap = true})
vim.api.nvim_set_keymap('i', '<A-j>', '<Esc>:m .+1<CR>==gi', { noremap = true})
vim.api.nvim_set_keymap('i', '<A-k>', '<Esc>:m .-2<CR>==gi', { noremap = true})
vim.api.nvim_set_keymap('v', '<A-j>', ':m \'>+1<CR>gv=gv', { noremap = true})
vim.api.nvim_set_keymap('v', '<A-k>', ':m \'<-2<CR>gv=gv', { noremap = true})
-- find things using telescope
vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>fg', ':Telescope live_grep<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>fb', ':Telescope buffers<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>fh', ':Telescope help_tags<CR>', { noremap = true})
-- interact with git
vim.api.nvim_set_keymap('n', '<leader>gs', ':Git status --short<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>gd', ':Git diff<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>gds',' :Git diff --staged<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>ga', ':Git add %:p<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>gap',' :Git add -p<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>gc', ':Git commit -v<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>gp', ':Git push<CR>', { noremap = true})

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- remap space as leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('lazy').setup('plugins', {
  ui = {
    icons = {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤',
    },
  },
  change_detection = {
    notify = false,
  },
})

local group = vim.api.nvim_create_augroup('my_vimrc', { clear = true })

-- Plug('mfussenegger/nvim-dap')
-- Plug('leoluz/nvim-dap-go')
-- Plug('fatih/vim-go', { ['do'] = ':GoUpdateBinaries' })
-- require('my.go')

-- Plug('prettier/vim-prettier', { ['do'] = 'npm install' })

-- looks
local default_mouse = function()
  vim.o.mouse = 'v'
  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.o.signcolumn = 'auto' -- only show signcolumn on errors
end

default_mouse()
vim.o.termguicolors = true
vim.o.textwidth = 100 -- longer lines will be broken up
vim.o.cursorline = true
vim.o.wrap = false
vim.o.listchars = 'tab:>-,trail:*,eol:¬' -- define how whitespace is shown
vim.o.showmode = false
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = group,
})

vim.o.errorbells = false

vim.o.tabstop = 4 -- size of a hard tabstop
vim.o.shiftwidth = 4 -- size of an "indent"
vim.o.softtabstop = 4
vim.o.shiftround = true -- round indent to multiple of 'shiftwidth'
vim.o.expandtab = true

vim.o.swapfile = false
vim.o.autowrite = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.hidden = true
-- used to trigger the CursorHold autocommand event sooner than default (4000ms)
-- relied on by for example the treesitter-playground query_linter and vim-go
-- for highlighting identifiers and showing the current function signature
-- (note there is also g:go_updatetime which I could use instead)
vim.o.updatetime = 400

vim.o.completeopt = 'menuone,noselect' -- to have a better completion experience
vim.o.wildmode = 'list:longest,full' -- shows list of commands when doing completion in cmd line via tab
-- search options
vim.o.hlsearch = false -- stop highlighting when I am done searching
vim.o.incsearch = true -- highlight search results while typing
vim.o.ignorecase = true -- search ignoring case...
vim.o.smartcase = true -- but not when search pattern has upper case character

-- sync clipboard between OS and Neovim
vim.o.clipboard = 'unnamedplus'

-- important for vim-go
-- used for auto_type_info adjust if needed, default is 800ms
vim.opt.shortmess:append({ c = false }) -- don't pass messages to |ins-completion-menu|

vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost' }, {
  command = 'silent! wall',
  group = group,
  desc = 'write modified buffers',
})
-- automatically rebalance windows on vim resize (useful when creating tmux
-- panes, so that vim splits are not looking like they are hidden)
vim.api.nvim_create_autocmd('VimResized', {
  command = ':wincmd =',
  group = group,
})

vim.cmd([[
  filetype plugin indent on
]])

-- Toggle to disable mouse mode and indentlines for easier paste
local toggle_mouse = function()
  if vim.wo.number then
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = 'no'
  else
    default_mouse()
  end
end

local opts = { silent = true }
vim.keymap.set('n', '<leader>cc', function()
  toggle_mouse()
  if vim.diagnostic.is_disabled(0) then
    vim.diagnostic.show(nil, 0)
  else
    vim.diagnostic.hide(nil, 0)
  end
end, opts)

require('navigation')
require('globals')

-- open file finder only if neovim is started without arguments
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local file_args = vim.tbl_filter(function(arg)
      return not vim.startswith(arg, 'nvim') and not vim.startswith(arg, '-')
    end, vim.v.argv)

    if vim.tbl_isempty(file_args) then
      require('plugins.telescope.functions').project_find_files()
    end
  end,
  once = true,
  group = group,
})

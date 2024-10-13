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

require('navigation')
require('globals')

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

vim.o.mouse = 'a'
-- remove the "How-to disable mouse" item
vim.cmd([[
  aunmenu PopUp.How-to\ disable\ mouse
  aunmenu PopUp.-2-
]])
-- looks
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.signcolumn = 'auto' -- only show signcolumn on errors
vim.o.termguicolors = true
vim.o.textwidth = 100 -- longer lines will be broken up
vim.o.wrap = false
vim.o.cursorline = true
vim.opt.listchars = { tab = '>-', trail = '*', eol = '¬' } -- define how whitespace is shown
vim.o.showmode = false
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = group,
})

vim.o.errorbells = false

vim.o.tabstop = 2 -- size of a hard tabstop
vim.o.shiftwidth = 2 -- size of an "indent"
vim.o.softtabstop = 2
vim.o.shiftround = true -- round indent to multiple of 'shiftwidth'
vim.o.expandtab = true
vim.o.breakindent = true

vim.o.swapfile = false
vim.o.autowrite = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.hidden = true
-- used to trigger the CursorHold autocommand event sooner than default (4000ms)
-- relied on by for example the treesitter-playground query_linter
vim.o.updatetime = 250
-- needs to be > than my voyager auto-shift timeout + typing speed as I cannot trigger sequences like ]d to jump to diagnostics while the non-shifted sequence [d will work just fine
vim.o.timeoutlen = 500

vim.opt.completeopt = { 'menu', 'menuone', 'noinsert' } -- to have a better completion experience
vim.o.wildmode = 'list:longest,full' -- shows list of commands when doing completion in cmd line via tab
-- search options
vim.o.hlsearch = false -- stop highlighting when I am done searching
vim.o.incsearch = true -- highlight search results while typing
-- case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true -- search ignoring case...
vim.o.smartcase = true -- but not when search pattern has upper case character

vim.o.undofile = true
-- sync clipboard between OS and Neovim
vim.o.clipboard = 'unnamedplus'

-- this is so that gq formats using formatters registered with conform (falls back to LSP) this will
-- also be used by rest.vim to format response bodies
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

-- important for vim-go
-- used for auto_type_info adjust if needed, default is 800ms
vim.opt.shortmess:append({ c = false }) -- don't pass messages to |ins-completion-menu|

vim.diagnostic.config({
  float = {
    source = true,
    border = 'rounded',
  },
})

vim.api.nvim_create_autocmd('StdinReadPost', {
  command = 'set nomodified',
  group = group,
  desc = "don't set modified when reading from stdin",
})
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost' }, {
  command = 'silent! wall',
  group = group,
  desc = 'write modified buffers',
})
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '.tmux.conf',
  command = '!tmux source-file %',
  group = group,
  desc = 'reload tmux config',
})
-- automatically rebalance windows on vim resize (useful when creating tmux
-- panes, so that vim splits are not looking like they are hidden)
vim.api.nvim_create_autocmd('VimResized', {
  command = ':wincmd =',
  group = group,
  desc = 'rebalance vim splits',
})

vim.cmd([[
  filetype plugin indent on
]])

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
  desc = 'open telescope on entering vim without a filepath',
})

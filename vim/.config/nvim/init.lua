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

require('lazy').setup('plugins')

local group = vim.api.nvim_create_augroup('my_vimrc', { clear = true })

-- Plug('tpope/vim-repeat')
-- Plug('tpope/vim-surround')

-- Plug('neovim/nvim-lspconfig') -- default configs for LSPs
--
-- -- autocompletion
-- Plug('hrsh7th/nvim-cmp')
-- Plug('hrsh7th/cmp-buffer')
-- Plug('hrsh7th/cmp-path')
-- Plug('hrsh7th/cmp-nvim-lua')
-- Plug('hrsh7th/cmp-nvim-lsp')
-- Plug('hrsh7th/cmp-cmdline')
-- Plug('saadparwaiz1/cmp_luasnip')
-- Plug('L3MON4D3/LuaSnip')             -- snippet engine
-- Plug('rafamadriz/friendly-snippets') -- actual snippets
-- Plug('onsails/lspkind-nvim')         -- beautify items
--
-- Plug('mfussenegger/nvim-jdtls')      -- Java LSP
-- Plug('mfussenegger/nvim-lint')
-- Plug('mfussenegger/nvim-dap')
-- Plug('leoluz/nvim-dap-go')
-- Plug('fatih/vim-go', { ['do'] = ':GoUpdateBinaries' })
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
vim.cmd.colorscheme('dogrun')
vim.o.textwidth = 100 -- longer lines will be broken up
vim.o.cursorline = true
vim.o.laststatus = 1
vim.o.wrap = false
vim.o.listchars = 'tab:>-,trail:*,eol:¬' -- define how whitespace is shown
-- increase contrast to so whitespace is easily visible (when showing it with
-- :set list!<CR>)
-- also set diagnostic highlights as vim-dogrun does not do it
vim.cmd([[
  highlight NonText guifg=#4a4a59
  highlight SpecialKey guifg=#4a4a59
  highlight LineNr guifg=#535f98
  highlight CursorLineNr guifg=#535f98

  highlight DiagnosticError guifg=#dc6f79 ctermfg=167
  highlight DiagnosticWarn guifg=#ac8b83 ctermfg=138
  highlight DiagnosticInfo guifg=#82dabf ctermfg=115
  highlight DiagnosticHint guifg=#82dabf ctermfg=115
]])
vim.fn.sign_define('DiagnosticSignError', { text = '', numhl = 'CocErrorSign' })
vim.fn.sign_define('DiagnosticSignWarn', { text = '', numhl = 'CocWarningSign' })
vim.fn.sign_define('DiagnosticSignInformation', { text = '', numhl = 'CocInfoSign' })
vim.fn.sign_define('DiagnosticSignHint', { text = '', numhl = 'CocHintSign' })
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
  return toggle_mouse()
end, opts)

require('navigation')
require('statusline')

-- require('my.cmp')
-- require('my.globals')
-- require('my.go')
-- require('my.lint')
-- require('my.lsp')
-- require('my.luasnip')

-- vim.api.nvim_create_autocmd('FileType', {
--   callback = function()
--     require('my.lint').enable_lint()
--   end,
--   group = group,
-- })
--

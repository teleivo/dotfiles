local group = vim.api.nvim_create_augroup('my_vimrc', { clear = true })
-- https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
-- TODO replace with lua :)
vim.cmd([[
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
]])

local install_path = vim.fn.stdpath('data') .. '/plugged'
local Plug = vim.fn['plug#']
vim.call('plug#begin', install_path)
Plug('wadackel/vim-dogrun')

-- git
Plug('nvim-lua/plenary.nvim')
Plug('lewis6991/gitsigns.nvim')
Plug('tpope/vim-fugitive')
Plug('tpope/vim-rhubarb')

Plug('tpope/vim-repeat')
Plug('tpope/vim-surround')
Plug('Raimondi/delimitMate')
Plug('AndrewRadev/splitjoin.vim')

Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim')
Plug('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = 'make' })
Plug('nvim-telescope/telescope-dap.nvim')
Plug('cljoly/telescope-repo.nvim')
Plug('teleivo/telescope-test.nvim')

Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('nvim-treesitter/nvim-treesitter-textobjects')
Plug('nvim-treesitter/playground')
Plug('neovim/nvim-lspconfig') -- default configs for LSPs
Plug('numToStr/Comment.nvim')

-- autocompletion
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-path')
Plug('hrsh7th/cmp-nvim-lua')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-cmdline')
Plug('saadparwaiz1/cmp_luasnip')
Plug('L3MON4D3/LuaSnip') -- snippet engine
Plug('rafamadriz/friendly-snippets') -- actual snippets
Plug('onsails/lspkind-nvim') -- beautify items

Plug('mfussenegger/nvim-jdtls') -- Java LSP
Plug('mfussenegger/nvim-lint')
Plug('mfussenegger/nvim-dap')
Plug('leoluz/nvim-dap-go')
Plug('fatih/vim-go', { ['do'] = ':GoUpdateBinaries' })
Plug('prettier/vim-prettier', { ['do'] = 'npm install' })

Plug('christoomey/vim-tmux-navigator')
vim.call('plug#end')

-- looks
vim.o.termguicolors = true
vim.cmd([[colorscheme dogrun]])
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.textwidth = 79 -- lines longer than 79 columns will be broken up
vim.o.signcolumn = 'auto' -- only show signcolumn on errors
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

-- remap space as leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

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

-- save the file on focus out only if modified
vim.api.nvim_create_autocmd('FocusLost', {
  command = 'if &mod | :w | endif',
  group = group,
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

require('navigation')
require('statusline')

require('my.cmp')
require('my.comment')
require('my.git')
require('my.globals')
require('my.go')
require('my.lint')
require('my.lsp')
require('my.luasnip')
require('my.telescope')
require('my.tmux')
require('my.treesitter')

vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    require('my.lint').enable_lint()
  end,
  group = group,
})

-- open file finder only if neovim is started without arguments
-- if vim.tbl_count(vim.v.argv) == 1 then
--   -- require('my.telescope.functions').project_files()
--   require('telescope.builtin').git_files({})
-- end

-- https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
vim.cmd([[
if empty(glob(stdpath('data') . '/site/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
]])

local install_path = vim.fn.stdpath('data') .. '/plugged'
local Plug = vim.fn['plug#']
vim.call('plug#begin', install_path)
Plug('wadackel/vim-dogrun')

Plug('tpope/vim-fugitive')
Plug('tpope/vim-surround')
Plug('tpope/vim-commentary')

Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim')
Plug('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = 'make' })

Plug('prettier/vim-prettier')
Plug('Raimondi/delimitMate')

Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('nvim-treesitter/nvim-treesitter-textobjects')
Plug('nvim-treesitter/playground')
Plug('neovim/nvim-lspconfig') -- default configs for LSPs
Plug('hrsh7th/nvim-cmp') -- autocompletion
Plug('hrsh7th/cmp-nvim-lsp') -- tells LSP of autocompletoin capabilities
Plug('saadparwaiz1/cmp_luasnip') -- autocompletion source
Plug('L3MON4D3/LuaSnip') -- Snippet engine

Plug('fatih/vim-go', { ['do'] = ':GoUpdateBinaries' })
Plug('AndrewRadev/splitjoin.vim')
Plug('christoomey/vim-tmux-navigator')
vim.call('plug#end')

-- looks
vim.o.termguicolors = true
vim.cmd [[colorscheme dogrun]]
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.textwidth = 79 -- lines longer than 79 columns will be broken up
vim.o.signcolumn = 'auto' -- only show signcolumn on errors
vim.o.cursorline = true
vim.o.laststatus = 1
vim.o.wrap = false
vim.o.listchars = 'tab:>-,trail:*,eol:¬' -- define how whitespaces are shown

-- remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.errorbells = false

vim.o.tabstop = 4 -- size of a hard tabstop
vim.o.shiftwidth = 4 -- size of an "indent"
vim.o.softtabstop = 4
vim.o.shiftround = true -- round indent to multiple of 'shiftwidth'
vim.o.expandtab = true

vim.o.autowrite = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.hidden = true

vim.o.scrolloff = 8
vim.o.completeopt = 'menuone,noselect' -- to have a better completion experience
vim.o.wildmode = 'list:longest,full' -- shows list of commands when doing completion in cmd line via tab
-- search options
vim.o.hlsearch = false -- stop highlighting when I am done searching
vim.o.incsearch = true -- highlight search results while typing
vim.o.ignorecase = true -- search ignoring case...
vim.o.smartcase = true -- but not when search pattern has upper case character

-- important for vim-go
-- used for auto_type_info adjust if needed, default is 800ms
vim.opt.shortmess:append({c = false }) -- don't pass messages to |ins-completion-menu|

require('navigation')
vim.cmd('source $HOME/.config/nvim/general.vimrc')
vim.cmd('source $HOME/.config/nvim/plugins.vimrc')

-- https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
vim.cmd [[
if empty(glob(stdpath('data') . '/site/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
]]

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
Plug('neovim/nvim-lspconfig') -- default configs for LSPs
Plug('hrsh7th/nvim-cmp') -- autocompletion
Plug('hrsh7th/cmp-nvim-lsp') -- tells LSP of autocompletoin capabilities
Plug('saadparwaiz1/cmp_luasnip') -- autocompletion source
Plug('L3MON4D3/LuaSnip') -- Snippet engine

Plug('fatih/vim-go', { ['do'] = ':GoUpdateBinaries' })
Plug('AndrewRadev/splitjoin.vim')
Plug('christoomey/vim-tmux-navigator')
vim.call('plug#end')

vim.cmd('source $HOME/.config/nvim/general.vimrc')
vim.cmd('source $HOME/.config/nvim/plugins.vimrc')
vim.cmd('source $HOME/.config/nvim/keys.vimrc')

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

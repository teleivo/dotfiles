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
Plug('tpope/vim-fugitive')
Plug('tpope/vim-surround')
Plug('tpope/vim-commentary')

Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim')
Plug('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = 'make' })

Plug('wadackel/vim-dogrun')
Plug('prettier/vim-prettier')
Plug('Raimondi/delimitMate')
Plug('neoclide/coc.nvim', { branch = 'release' })
Plug('fatih/vim-go', { ['do'] = ':GoUpdateBinaries' })
Plug('SirVer/ultisnips')
Plug('AndrewRadev/splitjoin.vim')
Plug('christoomey/vim-tmux-navigator')
vim.call('plug#end')

vim.cmd('source $HOME/.config/nvim/general.vimrc')
vim.cmd('source $HOME/.config/nvim/plugins.vimrc')
vim.cmd('source $HOME/.config/nvim/keys.vimrc')

" https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
if empty(glob(stdpath('data') . '/site/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(stdpath('data') . '/plugged')
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
" fzf installed using git
Plug '~/.fzf'
Plug 'junegunn/fzf.vim'
Plug 'wadackel/vim-dogrun'
Plug 'prettier/vim-prettier'
Plug 'Raimondi/delimitMate'
Plug 'junegunn/goyo.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'kovisoft/paredit', { 'for': 'clojure' }
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
Plug 'venantius/vim-cljfmt', { 'for': 'clojure'}
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'SirVer/ultisnips'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'christoomey/vim-tmux-navigator'
call plug#end()

source $HOME/.config/nvim/general.vimrc
source $HOME/.config/nvim/plugins.vimrc
source $HOME/.config/nvim/keys.vimrc

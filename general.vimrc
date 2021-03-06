colorscheme dogrun
set termguicolors
syntax on                           " syntax highlighting
"Invisible character colors
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59

set encoding=utf-8
set noerrorbells                    " no beeps
set autowrite                       " write buffer on make
set autoread                        " reread changes without asking
set relativenumber                  " show relative line numbers
set textwidth=79                    " lines longer than 79 columns will be broken
set wrap                            " to handle long lines
set cursorline                      " colors the current line differently during insert
set listchars=tab:>-,trail:*,eol:¬  " define how whitespaces are shown
" important for vim-go and coc
" used for auto_type_info adjust if needed, default is 800ms
set updatetime=100

set tabstop=4                       " size of a hard tabstop
set shiftwidth=4                    " size of an "indent"
set softtabstop=4
set shiftround                      " round indent to multiple of 'shiftwidth'
set expandtab

set modelines=0
set backspace=indent,eol,start      " backspace did not work in mintty

set showcmd
set cmdheight=2
set laststatus=2

set wildmenu                        " enables a menu at the bottom
set wildmode=list:longest,full      " shows list of commands when doing completion in cmd line via tab

set history=200                     " keep history of # ex commands
set ruler                           " shows ruler at the bottom right

set timeout timeoutlen=1500
set clipboard^=unnamed,unnamedplus  " make Vim use the system clipboard on mac/win/linux (also its selection clipboard)
set pastetoggle=<F3>                " toggle 'paste' to disable autoindent on pasting

set ignorecase                      " search ignoring case...
set smartcase                       " but not when search pattern has upper case character
set gdefault                        " replace all occurances on substitutions
set incsearch                       " highlight search results while typing
set showmatch
set hlsearch

" settings suggested by code completion
" https://github.com/neoclide/coc.nvim#example-vim-configuration
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup
" TextEdit might fail if hidden is not set.
set hidden
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c
" Only show signcolumn on errors
set signcolumn=auto

filetype plugin indent on
autocmd BufNewFile,BufRead *.md set filetype=markdown
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd Filetype puppet setlocal ts=2 sts=2 sw=2
autocmd Filetype go setlocal noexpandtab ts=4 sw=4
autocmd FocusLost * :wa                  " Set vim to save the file on focus out.

function! s:statusline_expr()
  let mod = "%{&modified ? '[+] ' : !&modifiable ? '[x] ' : ''}"
  let ro  = "%{&readonly ? '[RO] ' : ''}"
  let ft  = "%{len(&filetype) ? '['.&filetype.'] ' : ''}"
  let git = "%{exists('g:loaded_fugitive') ? fugitive#statusline() : ''}"
  let sep = ' %= '
  let pos = ' %-12(%l : %c%V%) '
  let pct = ' %P'

  return '[%n] %F %<'.mod.ro.ft.git.sep.pos.'%*'.pct
endfunction
let &statusline = s:statusline_expr()

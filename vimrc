" ============================================================================
" VIM-PLUG BLOCK {{{
" ============================================================================
" https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" fzf installed using Homebrew
" https://github.com/junegunn/fzf/blob/master/README-VIM.md#installation
set rtp+=/usr/local/opt/fzf

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'morhetz/gruvbox'
Plug 'jamessan/vim-gnupg'
Plug 'prettier/vim-prettier'
Plug 'editorconfig/editorconfig-vim'
Plug 'Raimondi/delimitMate'
Plug 'junegunn/goyo.vim'
Plug 'fatih/vim-go'
call plug#end()

" to ensure editorconfig plays nice with fugitive
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

filetype plugin indent on    " required

"
" Settings
"
colorscheme gruvbox
let g:gruvbox_contrast_dark='medium'

set background=dark

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

let g:tf_fmt_autosave = 0

set encoding=utf-8
set noerrorbells                    " no beeps
set autoread                        " reread changes without asking
set number                          " show line numbers
set textwidth=79                    " lines longer than 79 columns will be broken
set wrap                            " to handle long lines
set cursorline                      " colors the current line differently during insert
set listchars=tab:>-,trail:*,eol:¬  " define how whitespaces are shown

syntax on                           " syntax highlighting

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

au FocusLost * :wa                  " Set vim to save the file on focus out.

if has("autocmd")
    filetype plugin indent on
    autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
    autocmd Filetype puppet setlocal ts=2 sts=2 sw=2
    autocmd Filetype go setlocal noexpandtab ts=4 sw=4
endif

"
" Key mappings
"
let mapleader=" "
" shortcuts for opening files located in the same directory as the current file
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

"cursor should move down a single row on the screen
nmap j gj
nmap k gk
" automatically insert this before search to change regex behavior
nnoremap / /\v
vnoremap / /\v
" clear search results
nnoremap <leader><space> :noh<cr>
" center on search results when paging through
nnoremap n nzzzv
nnoremap N Nzzzv

" match bracket pairs when moving with tab
nnoremap <tab> %
vnoremap <tab> %

" get rid of help key
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" stay on home keys for ESC
inoremap jj <ESC>

" quickly open vimrc file in split window
nnoremap <leader>vrc <C-w><C-v><C-l>:e $MYVIMRC<cr>

" quickly save
nmap <leader>w :w!<cr>

" quickly close quickfix list
nnoremap <leader>a :cclose<CR>

" quickly jump between errors in quickfix list
map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>

" Shortcut to rapidly toggle set list
nmap <leader>l :set list!<CR>
"Invisible character colors
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59

" open nerdtree toggle
map <C-n> :NERDTreeToggle<CR>

nnoremap <C-p> :<C-u>FZF<CR>

" Better split switching
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" in normal mode Space toggles current fold. if not on a fold moves to the
" right.
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> zf

"
" Plugin settings
"

"
" GnuPG Extension
"
" Tell the GnuPG plugin to armor new files.
let g:GPGPreferArmor=1

" Tell the GnuPG plugin to sign new files.
let g:GPGPreferSign=1

augroup GnuPGExtra
    " Set extra file options
    autocmd BufReadCmd,FileReadCmd *.\(gpg\|asc\|pgp\) call SetGPGOptions()
    " Automatically close unmodified files after inactivity.
    autocmd CursorHold *.\(gpg\|asc\|pgp\) quit
augroup END

function SetGPGOptions()
    setlocal noswapfile
    set viminfo=
    set updatetime=60000
    set foldmethod=marker
    set foldlevel=0
    set foldclose=all
    set foldopen=insert
    " make it harder to open folds by accident
    set foldopen=""
    " move cursor over word and press 'e' to obfuscate/unobfuscate it
    "noremap e g?iw
endfunction

" add go linter to runtime path
set rtp+=$GOPATH/src/github.com/golang/lint/misc/vim

"
" Fugitive
"
nnoremap <leader>ga :Git add %:p<CR><CR>
nnoremap <leader>gc :Gcommit -v<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gp :Gpush<CR>

"
" vim-go
"
let g:go_fmt_fail_silently = 0
let g:go_fmt_command = "goimports"
let g:go_metalinter_enabled = ['vet', 'golint']
let g:go_metalinter_autosave = 1
let g:go_list_type = "quickfix"
let g:go_autodetect_gopath = 1
let g:go_auto_sameids = 1
let g:go_highlight_space_tab_error = 0
let g:go_highlight_array_whitespace_error = 0
let g:go_highlight_trailing_whitespace_error = 0
let g:go_highlight_extra_types = 0
let g:go_highlight_operators = 0
let g:go_highlight_build_constraints = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1

au FileType go nmap <leader>r  <Plug>(go-run)
au FileType go nmap <leader>b  <Plug>(go-build)
au FileType go nmap <leader>t  <Plug>(go-test)
au FileType go nmap <leader>tf <Plug>(go-test-func)
au FileType go nmap <Leader>tc <Plug>(go-coverage-toggle)
au FileType go nmap <Leader>d  <Plug>(go-doc)
au FileType go nmap <Leader>i  <Plug>(go-info)

au Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
au Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
au Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
au Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')


" ============================================================================
" VIM-PLUG BLOCK {{{
" ============================================================================
" https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'wadackel/vim-dogrun'
Plug 'jamessan/vim-gnupg'
Plug 'prettier/vim-prettier'
Plug 'editorconfig/editorconfig-vim'
Plug 'Raimondi/delimitMate'
Plug 'junegunn/goyo.vim'

" Languages
Plug 'kovisoft/paredit', { 'for': 'clojure' }
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
Plug 'venantius/vim-cljfmt', { 'for': 'clojure'}

Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'SirVer/ultisnips'

Plug 'AndrewRadev/splitjoin.vim'
call plug#end()

"
" Settings
"
colorscheme dogrun

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

set encoding=utf-8
set noerrorbells                    " no beeps
set autowrite                       " write buffer on make
set autoread                        " reread changes without asking
set relativenumber                  " show relative line numbers
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

filetype plugin indent on
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd Filetype puppet setlocal ts=2 sts=2 sw=2
autocmd Filetype go setlocal noexpandtab ts=4 sw=4
autocmd FocusLost * :wa                  " Set vim to save the file on focus out.

"Invisible character colors
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59

"
" Plugin settings
"
let g:paredit_smartjump = 1

" to ensure editorconfig plays nice with fugitive
let g:EditorConfig_exclude_patterns = ['fugitive://.*']
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
" TODO is this still needed?
set rtp+=$GOPATH/src/github.com/golang/lint/misc/vim

"
" vim-go
"
let g:go_fmt_fail_silently = 0
let g:go_fmt_command = "goimports"
let g:go_metalinter_enabled = ['vet', 'golint']
let g:go_metalinter_autosave = 1
let g:go_list_type = "quickfix"
set updatetime=100 " used for auto_type_info adjust if needed, default is 800ms
let g:go_auto_type_info = 1
let g:go_autodetect_gopath = 1
let g:go_auto_sameids = 1
let g:go_highlight_space_tab_error = 0
let g:go_highlight_array_whitespace_error = 0
let g:go_highlight_trailing_whitespace_error = 0
let g:go_highlight_extra_types = 0
let g:go_highlight_operators = 0
let g:go_highlight_build_constraints = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 0
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_methods = 1

" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

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

" jump between matching bracket pairs with tab
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
" open nerdtree toggle
map <C-n> :NERDTreeToggle<CR>

" search files with fzf :Files
nnoremap <C-p> :<C-u>Files<CR>

" Better split switching
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" in normal mode Space toggles current fold. if not on a fold moves to the
" right.
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> zf
nnoremap <Leader>g  :G<space>
nmap     <Leader>gs :Gstatus<CR>gg<c-n>
nnoremap <Leader>gd :Gdiff<CR>
nnoremap <leader>ga :Git add %:p<CR><CR>
nnoremap <leader>gp :Gpush<CR>

autocmd FileType go nmap <leader>r  <Plug>(go-run)
autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
autocmd FileType go nmap <leader>t  <Plug>(go-test)
autocmd FileType go nmap <leader>tf <Plug>(go-test-func)
autocmd FileType go nmap <Leader>tc <Plug>(go-coverage-toggle)
autocmd FileType go nmap <Leader>d  <Plug>(go-doc)
autocmd FileType go nmap <Leader>i  <Plug>(go-info)

autocmd Filetype clojure nmap <c-c><c-k> :Require<cr>

"
" Commands
"
autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')

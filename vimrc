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
Plug 'neoclide/coc.nvim', {'branch': 'release'}
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
" important for vim-go and coc
" used for auto_type_info adjust if needed, default is 800ms
set updatetime=100

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

" settings suggested by code completion
" https://github.com/neoclide/coc.nvim#example-vim-configuration
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup
" TextEdit might fail if hidden is not set.
set hidden
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c
if has("patch-8.1.1564")
  set signcolumn=number
else
  set signcolumn=yes
endif

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
" code completion
let g:coc_disable_startup_warning = 1

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

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

"
" vim-go
"
let g:go_fmt_fail_silently = 0
let g:go_fmt_command = "goimports"
let g:go_metalinter_enabled = ['vet', 'golint']
let g:go_metalinter_autosave = 1
let g:go_list_type = "quickfix"
let g:go_auto_type_info = 1
let g:go_autodetect_gopath = 1

let g:go_auto_sameids = 0
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
" disable vim-go :GoDef short cut (gd)
" this is handled by LanguageClient [LC]
let g:go_def_mapping_enabled = 0

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
noremap <leader>n :NERDTreeToggle<CR>

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

" fugitive mappings
nnoremap <Leader>gs :Git status --short<CR>
nnoremap <Leader>gd :Git diff<CR>
nnoremap <Leader>gds :Git diff --staged<CR>
nnoremap <leader>ga :Git add %:p<CR>
nnoremap <leader>gap :Git add -p<CR>
nnoremap <Leader>gc :Git commit<CR>
nnoremap <leader>gp :Git push<CR>

autocmd FileType go nmap <leader>r  <Plug>(go-run)
autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
autocmd FileType go nmap <leader>t  <Plug>(go-test)
autocmd FileType go nmap <leader>tf <Plug>(go-test-func)
autocmd FileType go nmap <Leader>tc <Plug>(go-coverage-toggle)
autocmd FileType go nmap <Leader>d  <Plug>(go-doc)
autocmd FileType go nmap <Leader>i  <Plug>(go-info)

autocmd Filetype clojure nmap <c-c><c-k> :Require<cr>

" code completion mappings
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-@> coc#refresh()

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> rn <Plug>(coc-rename)

"
" Commands
"
autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')

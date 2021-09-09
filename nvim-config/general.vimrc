colorscheme dogrun
set termguicolors
syntax on
"Invisible character colors
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59

set noerrorbells
set autowrite
set textwidth=79                    " lines longer than 79 columns will be broken up
set nowrap
set cursorline
set signcolumn=auto                 " Only show signcolumn on errors
set colorcolumn=100
set scrolloff=8
set listchars=tab:>-,trail:*,eol:¬  " define how whitespaces are shown
" important for vim-go
" used for auto_type_info adjust if needed, default is 800ms
set updatetime=100

set tabstop=4                       " size of a hard tabstop
set shiftwidth=4                    " size of an "indent"
set softtabstop=4
set shiftround                      " round indent to multiple of 'shiftwidth'
set expandtab

set shortmess+=c                    " Don't pass messages to |ins-completion-menu|
set laststatus=1
set wildmode=list:longest,full      " shows list of commands when doing completion in cmd line via tab
set history=200                     " keep history of # ex commands
set timeout timeoutlen=1500
set pastetoggle=<F3>                " toggle 'paste' to disable autoindent on pasting

" search options
set showmatch

set nobackup
set nowritebackup
set hidden

filetype plugin indent on
autocmd BufNewFile,BufRead *.md set filetype=markdown
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd Filetype go setlocal noexpandtab ts=4 sw=4
autocmd FocusLost * :wa " Set vim to save the file on focus out.
" automatically rebalance windows on vim resize (useful when creating tmux
" panes, so that vim splits are not looking like they are hidden)
autocmd VimResized * :wincmd =
" TODO the zoom does not always work
" zoom a vim pane, <C-w>= to re-balance
nnoremap <leader>- :wincmd _<cr>:wincmd \|<cr>
nnoremap <leader>= :wincmd =<cr>

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

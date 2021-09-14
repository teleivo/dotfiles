"Invisible character colors
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59

filetype plugin indent on
autocmd FocusLost * :wa " Set vim to save the file on focus out.
" automatically rebalance windows on vim resize (useful when creating tmux
" panes, so that vim splits are not looking like they are hidden)
autocmd VimResized * :wincmd =

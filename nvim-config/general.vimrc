"Invisible character colors
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59

filetype plugin indent on
autocmd BufNewFile,BufRead *.md set filetype=markdown
autocmd Filetype lua setlocal ts=2 sts=2 sw=2 expandtab
autocmd Filetype go setlocal noexpandtab ts=4 sw=4
autocmd FocusLost * :wa " Set vim to save the file on focus out.
" automatically rebalance windows on vim resize (useful when creating tmux
" panes, so that vim splits are not looking like they are hidden)
autocmd VimResized * :wincmd =

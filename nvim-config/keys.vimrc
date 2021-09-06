let mapleader=" "
" clear search results
nnoremap <leader><space> :noh<cr>
" quickly save
nmap <leader>w :w!<cr>
" quickly close quickfix list
nnoremap <leader>a :cclose<CR>
" toggle showing whitespace
nmap <leader>l :set list!<CR>

" fugitive mappings
nnoremap <leader>gs :Git status --short<CR>
nnoremap <leader>gd :Git diff<CR>
nnoremap <leader>gds :Git diff --staged<CR>
nnoremap <leader>ga :Git add %:p<CR>
nnoremap <leader>gap :Git add -p<CR>
nnoremap <leader>gc :Git commit -v<CR>
nnoremap <leader>gp :Git push<CR>

autocmd FileType go nmap <leader>r  <Plug>(go-run)
autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
autocmd FileType go nmap <leader>t  <Plug>(go-test)
autocmd FileType go nmap <leader>tf <Plug>(go-test-func)
autocmd FileType go nmap <leader>tc <Plug>(go-coverage-toggle)
autocmd FileType go nmap <leader>d  <Plug>(go-doc)
autocmd FileType go nmap <leader>i  <Plug>(go-info)

" movement
" cursor should move down a single row on the screen
nmap j gj
nmap k gk
" jump between matching bracket pairs with tab
nnoremap <tab> %
vnoremap <tab> %
" quickly jump between errors in quickfix list
map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
" Better split switching
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" search
" automatically insert this before search to change regex behavior
nnoremap / /\v
vnoremap / /\v
" center on search results when paging through
nnoremap n nzzzv
nnoremap N Nzzzv

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" get rid of help key
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" stay on home keys for ESC
inoremap jj <ESC>

" in normal mode Space toggles current fold. if not on a fold moves to the
" right.
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>

"
" Commands
"
autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')

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

" movement
" cursor should move down a single row on the screen
nmap j gj
nmap k gk

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

" stay on home keys for ESC
inoremap jj <ESC>

"
" Commands
"
autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')

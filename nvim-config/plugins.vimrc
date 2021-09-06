let g:paredit_smartjump = 1

" TODO still needed?
" remove ultisnips mapping of <tab> so it can be used by coc
" https://github.com/SirVer/ultisnips/issues/1052
let g:UltiSnipsExpandTrigger = "<nop>"

"
" vim-go
"
let g:go_fmt_fail_silently = 0
let g:go_fmt_command = "goimports"
let g:go_list_type = "quickfix"
let g:go_diagnostics_level = 2
let g:go_metalinter_command = "gopls"
let g:go_metalinter_autosave = 1
" don't jump to errors after metalinter is invoked
let g:go_jump_to_error = 0
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
let g:go_def_mapping_enabled = 1

" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

" Write all buffers before navigating from Vim to tmux pane
let g:tmux_navigator_save_on_switch = 2
" Disable tmux navigator when zooming the Vim pane
let g:tmux_navigator_disable_when_zoomed = 1

lua require('telescope.setup')
lua require('treesitter.setup')

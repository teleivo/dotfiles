vim.g.go_fmt_fail_silently = 0
vim.g.go_fmt_command = "goimports"
vim.g.go_diagnostics_level = 2
vim.g.go_metalinter_command = "gopls"
vim.g.go_metalinter_autosave = 1
vim.g.go_jump_to_error = 0
vim.g.go_auto_type_info = 0
vim.g.go_autodetect_gopath = 1
vim.g.go_template_use_pkg = 1
vim.g.go_auto_sameids = 1
vim.g.go_fold_enable = {}
vim.g.go_highlight_array_whitespace_error = 0
vim.g.go_highlight_chan_whitespace_error = 0
vim.g.go_highlight_extra_types = 0
vim.g.go_highlight_space_tab_error = 0
vim.g.go_highlight_trailing_whitespace_error = 0
vim.g.go_highlight_operators = 0
vim.g.go_highlight_functions = 0
vim.g.go_highlight_function_parameters = 0
vim.g.go_highlight_function_calls = 0
vim.g.go_highlight_types = 0
vim.g.go_highlight_fields = 0
vim.g.go_highlight_build_constraints = 0
vim.g.go_highlight_generate_tags = 0
vim.g.go_highlight_methods = 0
vim.g.go_highlight_string_spellcheck = 0
vim.g.go_highlight_format_strings = 0
vim.g.go_highlight_variable_declarations = 0
vim.g.go_highlight_variable_assignments = 0
vim.g.go_def_mapping_enabled = 0

vim.cmd([[
  autocmd FileType go nmap <leader>r  <Plug>(go-run)
  autocmd FileType go nmap <leader>t  <Plug>(go-test)
  autocmd FileType go nmap <leader>tf <Plug>(go-test-func)
  autocmd FileType go nmap <leader>tc <Plug>(go-coverage-toggle)
]])

vim.cmd([[
  autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
  autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
  autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
  autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')
]])

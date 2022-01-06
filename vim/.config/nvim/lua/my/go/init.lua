vim.g.go_gopls_enabled = false
vim.g.go_fmt_fail_silently = 0
vim.g.go_fmt_autosave = 0
vim.g.go_imports_autosave = 0
vim.g.go_mod_fmt_autosave = 0
vim.g.go_diagnostics_level = 0
vim.g.go_metalinter_command = 'gopls'
vim.g.go_metalinter_autosave = 0
vim.g.go_jump_to_error = 0
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

-- register the go adapter to debug go tests https://github.com/leoluz/nvim-dap-go
require('dap-go').setup()

-- from https://github.com/golang/tools/blob/master/gopls/doc/vim.md#imports
function goimports(timeout_ms)
  local context = { only = { 'source.organizeImports' } }
  vim.validate({ context = { context, 't', true } })

  local params = vim.lsp.util.make_range_params()
  params.context = context

  -- See the implementation of the textDocument/codeAction callback
  -- (lua/vim/lsp/handler.lua) for how to do this properly.
  local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, timeout_ms)
  if not result or next(result) == nil then
    return
  end
  local actions = result[1].result
  if not actions then
    return
  end
  local action = actions[1]

  -- textDocument/codeAction can return either Command[] or CodeAction[]. If it
  -- is a CodeAction, it can have either an edit, a command or both. Edits
  -- should be executed first.
  if action.edit or type(action.command) == 'table' then
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit)
    end
    if type(action.command) == 'table' then
      vim.lsp.buf.execute_command(action.command)
    end
  else
    vim.lsp.buf.execute_command(action)
  end
end

-- autoformat and organize imports
vim.cmd([[
  augroup GO_LSP
    autocmd!
    autocmd BufWritePre *.go :silent! lua vim.lsp.buf.formatting()
    autocmd BufWritePre *.go :silent! lua goimports(1000)
  augroup END
]])

vim.cmd([[
  autocmd FileType go nmap <leader>r  <Plug>(go-run)
  autocmd FileType go nmap <leader>t  <Plug>(go-test)
  autocmd FileType go nmap <leader>tf <Plug>(go-test-func)
  autocmd FileType go nmap <leader>tc <Plug>(go-coverage-toggle)
  autocmd FileType go nmap <silent> <leader>td :lua require('dap-go').debug_test()<cr>
]])

vim.cmd([[
  autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
  autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
  autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
  autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')
]])

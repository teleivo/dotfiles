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
vim.g.go_auto_sameids = 0
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
local function goimports(wait_ms)
  local params = vim.lsp.util.make_range_params()
  params.context = { only = { 'source.organizeImports' } }
  local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, wait_ms)
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        vim.lsp.util.apply_workspace_edit(r.edit, 'utf-16')
      else
        vim.lsp.buf.execute_command(r.command)
      end
    end
  end
end

-- autoformat and organize imports
local group = vim.api.nvim_create_augroup('my_go', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function()
    vim.lsp.buf.format()
    goimports(5000)
  end,
  group = group,
})

local key_mappings = {
  {
    'n',
    '<leader>r',
    '<Plug>(go-run)',
  },
  {
    'n',
    '<leader>t',
    '<Plug>(go-test)',
  },
  {
    'n',
    '<leader>tf',
    '<Plug>(go-test-func)',
  },
  {
    'n',
    '<leader>tc',
    '<Plug>(go-coverage-toggle)',
  },
  {
    'n',
    '<leader>td',
    function()
      require('dap-go').debug_test()
    end,
  },
}
local keymap = function()
  local opts = { silent = true }
  for _, mappings in pairs(key_mappings) do
    local mode, lhs, rhs = unpack(mappings)
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = keymap,
  group = group,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  command = "command! -bang A call go#alternate#Switch(<bang>0, 'edit')",
  group = group,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  command = "command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')",
  group = group,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  command = "command! -bang AS call go#alternate#Switch(<bang>0, 'split')",
  group = group,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  command = "command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')",
  group = group,
})

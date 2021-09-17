return {
  -- formatting
  {'n', 'gq', '<cmd>lua vim.lsp.buf.formatting()<cr>'},
  -- range formatting does not seem to work with gopls
  {'v', 'gq', '<esc><cmd>lua vim.lsp.buf.range_formatting()<cr>'},

  -- navigation
  {'n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>'},
  -- many servers do not implement this method, if it errors use definition
  {'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>'},
  {'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>'},
  {'n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<cr>'},
  -- NOTE that this overrides the default 'gi' behavior that I might want to
  -- add to my repertoire ;)
  {'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>'},
  -- search symbols using "f" since all my telescope mappings are prefixed with "f"
  {'n', '<leader>fs', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]]},

  -- documentation
  {'n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>'},
  {'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>'},

  -- code actions and refactoring
  -- {'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>'},
  -- `code_action` is a superset of vim.lsp.buf.code_action and you'll be able to
  -- use this mapping also with other language servers
  {'n', '<leader>ca', [[<cmd>lua require('jdtls').code_action()<cr>]]},
  {'v', '<leader>ca', [[<esc><cmd>lua require('jdtls').code_action(true)<cr>]]},
  -- TODO I get an error with gopls, the other two just say no code action
  {'n', '<leader>r', [[<cmd>lua require('jdtls').code_action(false, 'refactor')<cr>]]},
  {'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>'},

  -- diagnostics
  {'n', '<leader>dq', '<cmd>lua vim.lsp.diagnostic.set_qflist()<cr>'},
  {'n', '<leader>dl', '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>'},
  {'n', '<leader>ds', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>'},
  {'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>'},
  {'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>'},
}
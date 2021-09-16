return {
  {'n', 'gq', '<cmd>lua vim.lsp.buf.formatting()<cr>'},
  -- range formatting does not seem to work with gopls
  {'v', 'gq', '<esc><cmd>lua vim.lsp.buf.range_formatting()<cr>'},
  {'n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>'},
  {'n', 'gD', '<cmd>lua vim.lsp.buf.type_definition()<cr>'},
  {'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>'},
  {'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>'},
  {'n', 'K', '<cmd>lua vim.lsp.buf.hover()<Cr>'},
  {'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>'},
  {'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>'},
  {'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>'},
  {'n', '<leader>dq', '<cmd>lua vim.lsp.diagnostic.set_qflist()<cr>'},
  {'n', '<leader>dl', '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>'},
  {'n', '<leader>ds', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>'},
  {'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>'},
  {'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>'},
  -- search symbols using "f" since all my telescope mappings are prefixed with "f"
  {'n', '<leader>fs', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]]}
}

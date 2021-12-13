return {
  -- formatting
  { 'n', 'gq', '<cmd>lua vim.lsp.buf.formatting()<cr>' },
  -- range formatting does not seem to work with gopls
  { 'v', 'gq', '<esc><cmd>lua vim.lsp.buf.range_formatting()<cr>' },

  -- navigation
  { 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>' },
  -- many servers do not implement this method, if it errors use definition
  { 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>' },
  { 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>' },
  { 'n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<cr>' },
  -- NOTE that this overrides the default 'gi' behavior that I might want to
  -- add to my repertoire ;)
  { 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>' },
  -- search symbols using "f" since all my telescope mappings are prefixed with "f"
  { 'n', '<leader>fs', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>]] },

  -- documentation
  { 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>' },
  { 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>' },

  -- code actions and refactoring
  { 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>' },
  { 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>' },

  -- diagnostics
  { 'n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<cr>' },
  { 'n', '<leader>dq', '<cmd>lua vim.diagnostic.set_qflist()<cr>' },
  { 'n', '<leader>dl', '<cmd>lua vim.diagnostic.set_loclist()<cr>' },
  { 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>' },
  { 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>' },
}

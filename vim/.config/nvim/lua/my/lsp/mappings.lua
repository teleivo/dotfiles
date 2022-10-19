return {
  -- formatting
  { 'n', 'gq', vim.lsp.buf.format },
  -- range formatting does not seem to work with gopls
  { 'v', 'gq', vim.lsp.buf.format },

  -- navigation
  { 'n', 'gr', vim.lsp.buf.references },
  -- many servers do not implement this method, if it errors use definition
  { 'n', 'gD', vim.lsp.buf.declaration },
  { 'n', 'gd', vim.lsp.buf.definition },
  { 'n', 'gt', vim.lsp.buf.type_definition },
  -- NOTE that this overrides the default 'gi' behavior that I might want to
  -- add to my repertoire ;)
  { 'n', 'gi', vim.lsp.buf.implementation },
  -- search symbols using "f" since all my telescope mappings are prefixed with "f"
  {
    'n',
    '<leader>fs',
    function()
      return require('telescope.builtin').lsp_document_symbols()
    end,
  },

  -- documentation
  { 'n', 'K', vim.lsp.buf.hover },
  { 'n', '<C-k>', vim.lsp.buf.signature_help },

  -- code actions and refactoring
  { { 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action },
  { 'n', '<leader>rn', vim.lsp.buf.rename },

  -- diagnostics
  { 'n', '<leader>e', vim.diagnostic.open_float },
  { 'n', '[d', vim.diagnostic.goto_prev },
  { 'n', ']d', vim.diagnostic.goto_next },

  -- debugging
  {
    'n',
    '<leader>db',
    function()
      return require('dap').toggle_breakpoint()
    end,
  },
  {
    'n',
    '<leader>dc',
    function()
      return require('dap').continue()
    end,
  },
  {
    'n',
    '<leader>ds',
    function()
      return require('dap').step_over()
    end,
  },
  -- TODO why is that one not working?
  {
    'n',
    '<leader>di',
    function()
      return require('dap').step_into()
    end,
  },
  {
    'n',
    '<leader>do',
    function()
      return require('dap').step_out()
    end,
  },
  {
    'n',
    '<leader>dr',
    function()
      return require('dap').repl.open()
    end,
  },
  {
    'n',
    '<leader>dl',
    function()
      return require('dap').run_last()
    end,
  },
}

local M = {}

M.keymaps = {
  {
    'n',
    'grr',
    function()
      return require('telescope.builtin').lsp_references({
        reuse_win = true,
        include_declaration = false,
      })
    end,
    {
      desc = 'Search code references using LSP',
    },
  },
  {
    'n',
    'gd',
    function()
      return vim.lsp.buf.definition({ reuse_win = true })
      -- require('telescope.builtin').lsp_definitions({
      --   reuse_win = true,
      -- })
    end,
    {
      desc = 'Go to definition using LSP',
    },
  },
  -- TODO do I need this one
  -- many servers do not implement this method, if it errors use definition
  { 'n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to declaration using LSP' } },
  {
    'n',
    '<leader>ct',
    function()
      return require('telescope.builtin').lsp_type_definitions({
        reuse_win = true,
      })
    end,
    {
      desc = 'Go to type definition using LSP',
    },
  },
  {
    'n',
    '<leader>ci',
    function()
      return require('telescope.builtin').lsp_implementations({
        reuse_win = true,
      })
    end,
    {
      desc = 'Search implementations using LSP (go to if there is only one)',
    },
  },
  -- search symbols using "f" since all my telescope mappings are prefixed with "f"
  {
    'n',
    '<leader>fs',
    function()
      return require('telescope.builtin').lsp_document_symbols()
    end,
    {
      desc = 'Search symbols using LSP',
    },
  },
  -- documentation
  {
    { 'n', 'i' },
    '<C-k>',
    vim.lsp.buf.signature_help,
    {
      desc = 'Show signature help using LSP',
    },
  },
  {
    'n',
    'grf',
    function()
      vim.lsp.buf.code_action({
        context = { only = { 'source.organizeImports' } },
        apply = true,
      })
      vim.lsp.buf.code_action({
        context = { only = { 'source.fixAll' } },
        apply = true,
      })
    end,
    {
      desc = 'Organize imports and fix all using LSP',
    },
  },
  {
    'v',
    'grx',
    function()
      vim.lsp.buf.code_action({
        context = { only = { 'refactor.extract' } },
        apply = true,
      })
      -- TODO no way for me to know if and what action was applied. I would want to leave visual
      -- mode only when an action was actually applied. If not I want to be able to stay in
      -- visual mode to refine my selection
      -- https://github.com/neovim/neovim/issues/25259
      -- It would be great if the cursor would always be put on the extracted node. It does work
      -- for variables but not for functions. Not sure if that is the responsibility of the LSP.
      local esc = vim.api.nvim_replace_termcodes('<esc>', true, false, true)
      vim.api.nvim_feedkeys(esc, 'x', false)
    end,
    {
      desc = 'Extract visual selection into variable, function or method using LSP',
    },
    {
      'n',
      -- TODO how to disable default LSP mappings? I want this to be gri but that is taken and the help *lsp-defaults-disable* does not work
      'gry',
      function()
        vim.lsp.buf.code_action({
          context = { only = { 'refactor.inline' } },
          apply = true,
        })
      end,
      {
        desc = 'Inline variable or function using LSP',
      },
    },
  },
}

return M

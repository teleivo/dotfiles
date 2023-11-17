return {
  {
    'wadackel/vim-dogrun',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      ---         |hl-LspReferenceText|
      ---         |hl-LspReferenceRead|
      ---         |hl-LspReferenceWrite|
      vim.cmd.colorscheme('dogrun')
      -- increase contrast to so whitespace is easily visible (when showing it with
      -- :set list!<CR>)
      -- also set diagnostic highlights as vim-dogrun does not do it
      vim.cmd([[
        highlight NonText guifg=#4a4a59
        highlight SpecialKey guifg=#4a4a59
        highlight LineNr guifg=#535f98
        highlight CursorLineNr guifg=#535f98
      ]])
      vim.fn.sign_define('DiagnosticSignError', { text = '', numhl = 'CocErrorSign' })
      vim.fn.sign_define('DiagnosticSignWarn', { text = '', numhl = 'CocWarningSign' })
      vim.fn.sign_define('DiagnosticSignInformation', { text = '', numhl = 'CocInfoSign' })
      vim.fn.sign_define('DiagnosticSignHint', { text = '', numhl = 'CocHintSign' })
    end,
  },
}

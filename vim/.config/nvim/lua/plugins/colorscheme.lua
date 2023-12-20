return {
  {
    'wadackel/vim-dogrun',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      vim.cmd.colorscheme('dogrun')
      vim.cmd([[
        " https://github.com/wadackel/vim-dogrun/blob/940814494be4adb066d4eb96409a85cb84c0bd6b/colors/dogrun.vim#L34
        " increase contrast of LineNr by using the same values as for CursorLineNr
        highlight LineNr guifg=#535f98 ctermfg=61 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE

        " until https://github.com/wadackel/vim-dogrun/issues/17 is resolved
        highlight link LspReferenceText MatchParen
        highlight link LspReferenceRead MatchParen
        highlight link LspReferenceWrite MatchParen
        highlight link LspSignatureActiveParameter Visual
      ]])
      -- dogrun specifies highlight groups for the coc plugin (which I don't use) but this way I can reuse
      -- them for the diagnostic signs
      -- https://github.com/wadackel/vim-dogrun/blob/940814494be4adb066d4eb96409a85cb84c0bd6b/colors/dogrun.vim#L212-L215
      -- I only color the absolute/relative line numbers of lines with diagnostics without any symbol
      vim.fn.sign_define('DiagnosticSignError', { text = '', numhl = 'CocErrorSign' })
      vim.fn.sign_define('DiagnosticSignWarn', { text = '', numhl = 'CocWarningSign' })
      vim.fn.sign_define('DiagnosticSignInformation', { text = '', numhl = 'CocInfoSign' })
      vim.fn.sign_define('DiagnosticSignHint', { text = '', numhl = 'CocHintSign' })
    end,
  },
}

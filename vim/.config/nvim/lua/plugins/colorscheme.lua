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
        highlight link CursorLineNr LineNr
        " adjusted to my taste and I try to keep the telescope colors in sync with
        " my fzf config in ../../../../../shell/.zshrc
        " some colors do not show up correctly when linking them to the highlight group used by
        " dogrun. They do show up correctly if I copy the values though. Not sure what's going on.
        " highlight Normal
        highlight TelescopeNormal guifg=#9ea3c0 ctermfg=146 guibg=#222433 ctermbg=235
        highlight link TelescopeTitle Function
        " highlight Function
        highlight TelescopeMatching guifg=#929be5 ctermfg=104 gui=underline cterm=underline
        highlight link TelescopeBorder Comment
        highlight link TelescopePromptPrefix Function
        " highlight Function
        highlight TelescopePromptCounter guifg=#929be5 ctermfg=104 gui=NONE cterm=NONE
        " highlight Normal
        highlight TelescopeSelection guifg=#9ea3c0 ctermfg=146 guibg=#222433 ctermbg=235
        highlight link TelescopeSelectionCaret @keyword
        " highlight String
        highlight TelescopeMultiIcon guifg=#7cbe8c ctermfg=108
        " highlight Normal
        highlight TelescopeMultiSelection guifg=#9ea3c0 ctermfg=146 guibg=#222433 ctermbg=235
      ]])
      -- dogrun specifies highlight groups for the coc plugin (which I don't use) but this way I can reuse
      -- them for the diagnostic signs
      -- https://github.com/wadackel/vim-dogrun/blob/940814494be4adb066d4eb96409a85cb84c0bd6b/colors/dogrun.vim#L212-L215
      -- I only color the absolute/relative line numbers of lines with diagnostics without any symbol
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.INFO] = '',
            [vim.diagnostic.severity.HINT] = '',
          },
          linehl = {
            [vim.diagnostic.severity.ERROR] = 'CocErrorSign',
            [vim.diagnostic.severity.WARN] = 'CocWarningSign',
            [vim.diagnostic.severity.INFO] = 'CocInfoSign',
            [vim.diagnostic.severity.HINT] = 'CocHintSign',
          },
          numhl = {
            [vim.diagnostic.severity.ERROR] = 'CocErrorSign',
            [vim.diagnostic.severity.WARN] = 'CocWarningSign',
            [vim.diagnostic.severity.INFO] = 'CocInfoSign',
            [vim.diagnostic.severity.HINT] = 'CocHintSign',
          },
        },
      })
    end,
  },
}

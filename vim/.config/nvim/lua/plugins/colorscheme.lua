return {
  {
    'wadackel/vim-dogrun',
    lazy = false, -- load this during startup as it is my main colorscheme
    priority = 1000, -- load this before all the other start plugins
    config = function()
      vim.cmd.colorscheme('dogrun')
      -- increase contrast of CursorLineNr by using the same values as for LineNr
      vim.api.nvim_set_hl(0, 'CursorLineNr', { link = 'LineNr' })
      -- adjusted telescope and cmp to my taste and keeping it in sync with my fzf config in
      -- ../../../../../shell/.zshrc
      -- Telescope
      vim.api.nvim_set_hl(0, 'TelescopeNormal', { link = 'Normal' })
      vim.api.nvim_set_hl(0, 'TelescopeTitle', { link = 'Function' })
      vim.api.nvim_set_hl(0, 'TelescopePromptPrefix', { link = 'Function' })
      vim.api.nvim_set_hl(0, 'TelescopePromptCounter', { link = 'Function' })
      -- Function with underline
      vim.api.nvim_set_hl(0, 'TelescopeMatching', { fg = '#929be5', underline = true })
      vim.api.nvim_set_hl(0, 'TelescopeSelection', { link = 'Visual' })
      vim.api.nvim_set_hl(0, 'TelescopeSelectionCaret', { link = '@keyword' })
      vim.api.nvim_set_hl(0, 'TelescopeBorder', { link = 'Comment' })
      vim.api.nvim_set_hl(0, 'TelescopeMultiIcon', { link = 'String' })
      vim.api.nvim_set_hl(0, 'TelescopeMultiSelection', { link = 'Normal' })
      -- Cmp
      vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', { fg = '#929be5', bg = 'NONE', underline = true })
      vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { link = 'Function' })
      -- light red (dogrun Error)
      vim.api.nvim_set_hl(0, 'CmpItemAbbrDeprecated', { fg = '#dc6f79', strikethrough = true })
      vim.api.nvim_set_hl(0, 'CmpItemKindInterface', { link = '@lsp.type.interface' })
      vim.api.nvim_set_hl(0, 'CmpItemKindVariable', { link = '@lsp.type.variable' })
      vim.api.nvim_set_hl(0, 'CmpItemKindField', { link = 'Normal' })
      vim.api.nvim_set_hl(0, 'CmpItemKindText', { link = 'Normal' })
      vim.api.nvim_set_hl(0, 'CmpItemKindFunction', { link = 'Function' })
      vim.api.nvim_set_hl(0, 'CmpItemKindMethod', { link = 'Function' })
      vim.api.nvim_set_hl(0, 'CmpItemKindKeyword', { link = '@keyword' })
      vim.api.nvim_set_hl(0, 'CmpItemKindProperty', { link = '@keyword' })
      vim.api.nvim_set_hl(0, 'CmpItemKindUnit', { link = '@keyword' })
      vim.api.nvim_set_hl(0, 'CmpItemKindStruct', { link = '@keyword' })
      vim.api.nvim_set_hl(0, 'CmpItemKindModule', { link = 'Constant' })

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

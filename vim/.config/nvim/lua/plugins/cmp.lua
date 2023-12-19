return {
  {
    'hrsh7th/nvim-cmp',
    version = false, -- last release is way too old
    event = 'InsertEnter',
    -- these dependencies will only be loaded when cmp loads
    -- dependencies are always lazy-loaded unless specified otherwise
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'onsails/lspkind-nvim',
      'L3MON4D3/LuaSnip',
      'windwp/nvim-autopairs',
    },
    config = function()
      local cmp = require('cmp')
      local lspkind = require('lspkind')
      local luasnip = require('luasnip')

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
      end

      cmp.setup({
        enabled = function()
          -- disable completion in prompts like Telescope
          local buftype = vim.api.nvim_buf_get_option(0, 'buftype')
          if buftype == 'prompt' then
            return false
          end

          -- disable completion in comments
          local context = require('cmp.config.context')
          -- keep command mode completion enabled when cursor is in a comment
          if vim.api.nvim_get_mode().mode == 'c' then
            return true
          else
            return not context.in_treesitter_capture('comment') and not context.in_syntax_group('Comment')
          end
        end,
        formatting = {
          format = lspkind.cmp_format({
            preset = 'codicons',
            menu = {
              nvim_lua = '[API]',
              nvim_lsp = '[LSP]',
              path = '[path]',
              luasnip = '[snip]',
              buffer = '[buf]',
            },
          }),
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
          ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
          ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
          ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#confirm-candidate-on-tab-immediately-when-theres-only-one-completion-entry
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if #cmp.get_entries() == 1 then
                cmp.confirm({ select = true })
              else
                cmp.select_next_item()
              end
              -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
              -- that way you will only jump inside the snippet region
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
              if #cmp.get_entries() == 1 then
                cmp.confirm({ select = true })
              end
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<CR>'] = function(fallback)
            if cmp.visible() then
              cmp.confirm({ select = true })
            else
              fallback()
            end
          end,
        }),
        experimental = {
          ghost_text = true,
        },
        sources = {
          { name = 'nvim_lua' },
          { name = 'nvim_lsp' },
          { name = 'path' },
          { name = 'luasnip' },
          { name = 'buffer', keyword_length = 3 },
        },
      })

      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' },
        },
      })
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline({
          -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#confirm-candidate-on-tab-immediately-when-theres-only-one-completion-entry
          ['<Tab>'] = {
            c = function(_)
              if cmp.visible() then
                if #cmp.get_entries() == 1 then
                  cmp.confirm({ select = true })
                else
                  cmp.select_next_item()
                end
              else
                cmp.complete()
                if #cmp.get_entries() == 1 then
                  cmp.confirm({ select = true })
                end
              end
            end,
          },
        }),
        sources = cmp.config.sources({
          { name = 'path' },
        }, {
          {
            name = 'cmdline',
            option = {
              ignore_cmds = { 'Man', '!' },
            },
          },
        }),
      })

      -- to insert `(` after select function or method item
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

      vim.cmd([[
        " light red (dogrun Error)
        highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#dc6f79
        " pink
        highlight! CmpItemAbbrMatch guibg=NONE guifg=#b871b8
        highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#b871b8
        highlight! CmpItemKindInterface guibg=NONE guifg=#b871b8
        " grey (dogrun normal)
        highlight! CmpItemKindVariable guibg=NONE guifg=#9ea3c0
        highlight! CmpItemKindField guibg=NONE guifg=#9ea3c0
        highlight! CmpItemKindText guibg=NONE guifg=#9ea3c0
        " blue (dogrun Function)
        highlight! CmpItemKindFunction guibg=NONE guifg=#929be5
        highlight! CmpItemKindMethod guibg=NONE guifg=#929be5
        " light brown/orange?
        highlight! CmpItemKindKeyword guibg=NONE guifg=#ac8b83
        highlight! CmpItemKindProperty guibg=NONE guifg=#ac8b83
        highlight! CmpItemKindUnit guibg=NONE guifg=#ac8b83
        highlight! CmpItemKindStruct guibg=NONE guifg=#ac8b83
        " bright green
        highlight! CmpItemKindModule guibg=NONE guifg=#73c1a9
      ]])
    end,
  },
}

return {
  -- TODO fix luasnip tab navigation in Go test snippet, it does work in all, markdown snippets
  -- TODO how to prioritize snippets a bit over buffer?
  -- TODO search and cmdline behavior ok?
  -- TODO autopairs?
  -- TODO why is the completion not showing the callouts in my callout snippet when I am in [!]?
  -- TODO lsp hint seems to not be cleared at all times
  -- TODO try supermaven completion
  -- TODO add emoji source
  {
    'saghen/blink.cmp',
    dependencies = {
      { 'L3MON4D3/LuaSnip', version = 'v2.*' },
      {
        'saghen/blink.compat',
        version = '*',
        lazy = true,
        -- make sure to set opts so that lazy.nvim calls blink.compat's setup
        opts = {},
      },
    },
    version = '*',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default',
        ['<C-space>'] = {}, -- disable
        ['<C-e>'] = {
          function(cmp)
            if cmp.is_visible() then
              cmp.hide()
            else
              cmp.show()
            end
          end,
        },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      completion = {
        menu = {
          border = 'rounded',
          winhighlight = 'Normal:Normal,FloatBorder:Comment,CursorLine:Visual,Search:None',
          draw = {
            columns = {
              { 'label', 'label_description', gap = 1 },
              { 'kind_icon', gap = 1 },
              { 'kind' },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
          window = {
            border = 'rounded',
            winhighlight = 'Normal:Normal,FloatBorder:Comment,CursorLine:Visual,Search:None',
          },
        },
        ghost_text = { enabled = true },
      },
      signature = {
        enabled = true,
        window = {
          border = 'rounded',
          winhighlight = 'Normal:Normal,FloatBorder:Comment,CursorLine:Visual,Search:None',
        },
      },
      snippets = { preset = 'luasnip' },
      sources = {
        default = {
          'lazydev',
          'snippets',
          'lsp',
          'path',
          'buffer',
          'markdown',
          'dadbod',
          'avante_commands',
          'avante_mentions',
          -- 'avante_files',
        },
        providers = {
          avante_commands = {
            name = 'avante_commands',
            module = 'blink.compat.source',
            score_offset = 90, -- show at a higher priority than lsp
          },
          -- TODO what is this for?
          -- https://github.com/yetone/avante.nvim/pull/984/files
          -- avante_files = {
          --   name = 'avante_commands',
          --   module = 'blink.compat.source',
          --   score_offset = 100, -- show at a higher priority than lsp
          -- },
          avante_mentions = {
            name = 'avante_mentions',
            module = 'blink.compat.source',
            score_offset = 1000, -- show at a higher priority than lsp
          },
          dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
          -- luasnip = {
          --   name = 'Luasnip',
          --   module = 'blink.cmp.sources.luasnip',
          --   score_offset = 2, -- score higher than lsp
          --   opts = {
          --     use_show_condition = true,
          --     show_autosnippets = true,
          --   },
          -- },
          markdown = { name = 'RenderMarkdown', module = 'render-markdown.integ.blink' },
        },
      },
    },
    opts_extend = { 'sources.default' },
  },
}

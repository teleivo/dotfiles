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
      signature = { enabled = true },
      snippets = {
        expand = function(snippet)
          require('luasnip').lsp_expand(snippet)
        end,
        active = function(filter)
          if filter and filter.direction then
            return require('luasnip').jumpable(filter.direction)
          end
          return require('luasnip').in_snippet()
        end,
        jump = function(direction)
          require('luasnip').jump(direction)
        end,
      },
      sources = {
        default = { 'lazydev', 'luasnip', 'lsp', 'path', 'buffer', 'markdown', 'dadbod' },
        providers = {
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

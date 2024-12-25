return {
  -- TODO prioritize snippets over lsp
  -- TODO fix luasnip expansion
  -- TODO lsp hint seems to not be cleared at all times
  -- TODO lazydev setup
  -- TODO autopairs?
  -- TODO vim-dadbod-completion
  -- TODO search and cmdline behavior ok?
  {
    'saghen/blink.cmp',
    dependencies = { 'L3MON4D3/LuaSnip', version = 'v2.*' },
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
        default = { 'luasnip', 'lsp', 'path', 'buffer' },
      },
    },
    opts_extend = { 'sources.default' },
  },
}

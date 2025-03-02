return {
  -- TODO how to prioritize snippets a bit over buffer?
  -- TODO autopairs?
  -- TODO lsp hint seems to not be cleared at all times
  {
    'saghen/blink.cmp',
    dependencies = {
      { 'L3MON4D3/LuaSnip' },
      {
        'saghen/blink.compat',
        version = '*',
        lazy = true,
        opts = {},
      },
    },
    version = '*',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      enabled = function()
        return vim.bo.buftype ~= 'prompt' and vim.b.completion ~= false
      end,
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
        min_keyword_length = function(ctx)
          if ctx.mode ~= 'cmdline' then
            return 2
          -- only applies when typing a command, doesn't apply to arguments
          elseif ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil then
            -- 3 so completion does not show for short commands
            return 3
          end

          return 0
        end,
        default = {
          'lazydev',
          'snippets',
          'lsp',
          'path',
          'buffer',
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
        },
      },
    },
    opts_extend = { 'sources.default' },
  },
}

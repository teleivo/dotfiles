return {
  -- TODO how to prioritize snippets a bit over buffer?
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
        -- Using parts of the preset
        -- https://cmp.saghen.dev/configuration/keymap.html#default
        -- Completion is disabled by default and opened with C-n when needed
        ['<C-e>'] = { 'cancel' }, -- default is 'hide'
        ['<C-y>'] = { 'select_and_accept' },

        ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
        ['<C-n>'] = { 'show', 'select_next', 'fallback_to_mappings' }, -- default is without 'show'

        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

        ['<Tab>'] = { 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

        ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      completion = {
        menu = {
          auto_show = false, -- completion feels distracting try only using it when needed
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
        list = { selection = { preselect = true, auto_insert = true } },
        ghost_text = { enabled = false },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
          window = {
            border = 'rounded',
            winhighlight = 'Normal:Normal,FloatBorder:Comment,CursorLine:Visual,Search:None',
          },
        },
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
          'dadbod',
          'avante_commands',
          'avante_mentions',
          'avante_files',
        },
        providers = {
          avante_commands = {
            name = 'avante_commands',
            module = 'blink.compat.source',
            score_offset = 90, -- show at a higher priority than lsp
            opts = {},
          },
          avante_files = {
            name = 'avante_files',
            module = 'blink.compat.source',
            score_offset = 100, -- show at a higher priority than lsp
            opts = {},
          },
          avante_mentions = {
            name = 'avante_mentions',
            module = 'blink.compat.source',
            score_offset = 1000, -- show at a higher priority than lsp
            opts = {},
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

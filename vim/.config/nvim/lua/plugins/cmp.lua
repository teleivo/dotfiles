return {
  {
    'hrsh7th/nvim-cmp',
    version = false, -- last release is way too old
    event = { 'InsertEnter', 'CmdlineEnter' },
    -- these dependencies will only be loaded when cmp loads
    -- dependencies are always lazy-loaded unless specified otherwise
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'windwp/nvim-autopairs',
    },
    config = function()
      local cmp = require('cmp')
      local compare = require('cmp.config.compare')
      local luasnip = require('luasnip')
      local item_menu = {
        nvim_lua = '[api]',
        nvim_lsp = '[lsp]',
        path = '[path]',
        luasnip = '[snip]',
        buffer = '[buf]',
      }

      cmp.setup({
        -- preselect and completeopt settings lead to the first item being selected
        -- https://github.com/hrsh7th/nvim-cmp/issues/1621
        preselect = cmp.PreselectMode.None,
        completion = {
          completeopt = 'menu,menuone,noinsert',
        },
        enabled = function()
          -- disable completion in prompts like Telescope
          local buftype = vim.api.nvim_get_option_value('buftype', { buf = 0 })
          if buftype == 'prompt' then
            return false
          end

          return true
        end,
        window = {
          completion = cmp.config.window.bordered({
            winhighlight = 'Normal:Normal,FloatBorder:Comment,CursorLine:Visual,Search:None',
          }),
          documentation = cmp.config.window.bordered({
            winhighlight = 'Normal:Normal,FloatBorder:Comment,CursorLine:Visual,Search:None',
          }),
        },
        sorting = {
          comparators = {
            compare.exact,
            compare.scope,
            compare.kind,
            compare.length,
          },
        },
        formatting = {
          format = function(entry, item)
            item.menu = item_menu[entry.source.name] or entry.source.name
            return item
          end,
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = {
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<C-n>'] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.expand_or_locally_jumpable() then -- jump to next node in snippet
              luasnip.expand_or_jump()
            else
              cmp.complete()
            end
          end, { 'i', 's' }),
          ['<C-p>'] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.locally_jumpable(-1) then -- jump to previous node in snippet
              luasnip.jump(-1)
            else
              cmp.complete()
            end
          end, { 'i', 's' }),
          -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#confirm-candidate-on-tab-immediately-when-theres-only-one-completion-entry
          ['<C-y>'] = cmp.mapping(function()
            if luasnip.expandable() then
              luasnip.expand()
            elseif cmp.visible() or #cmp.get_entries() == 1 then
              cmp.confirm({ select = true })
            end
          end),
        },
        experimental = {
          ghost_text = true,
        },
        sources = {
          { name = 'luasnip' },
          { name = 'nvim_lua' },
          { name = 'nvim_lsp' },
          { name = 'buffer', keyword_length = 3 },
          { name = 'path' },
        },
      })

      -- use different sources and mappings on the cmdline
      -- here <Tab> and <CR> are useful to select an item as I don't use them for anything else like
      -- whitespace as in insert mode
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' },
        },
      })
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' },
          {
            name = 'cmdline',
            keyword_length = 2,
            option = {
              ignore_cmds = { 'Man', '!' },
            },
          },
        }),
      })
      cmp.setup.filetype({ 'sql' }, {
        sources = {
          { name = 'vim-dadbod-completion' },
          { name = 'buffer' },
        },
      })

      -- to insert `(` after select function or method item
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      -- cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
      local handlers = require('nvim-autopairs.completion.handlers')

      cmp.event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done({
          filetypes = {
            -- "*" is a alias to all filetypes
            ['*'] = {
              ['('] = {
                kind = {
                  cmp.lsp.CompletionItemKind.Function,
                  cmp.lsp.CompletionItemKind.Method,
                },
                handler = handlers['*'],
              },
            },
            -- Disable for Go as LSP autocomplete already inserts () pairs
            -- and I don't want autopairs to add pairs in comments (using ts_config did not work as
            -- the pairs come from the LSP).
            go = false,
          },
        })
      )

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

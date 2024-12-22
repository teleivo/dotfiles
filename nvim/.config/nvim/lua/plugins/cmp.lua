return {
  {
    'hrsh7th/nvim-cmp',
    version = false, -- last release is way too old
    event = { 'InsertEnter', 'CmdlineEnter' },
    -- these dependencies will only be loaded when cmp loads
    -- dependencies are always lazy-loaded unless specified otherwise
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
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
        window = {
          completion = cmp.config.window.bordered({
            winhighlight = 'Normal:Normal,FloatBorder:Comment,CursorLine:Visual,Search:None',
          }),
          documentation = cmp.config.window.bordered({
            winhighlight = 'Normal:Normal,FloatBorder:Comment,CursorLine:Visual,Search:None',
          }),
        },
        sorting = {
          priority_weight = 2,
          comparators = {
            compare.offset,
            compare.exact,
            compare.scopes,
            compare.score,
            compare.recently_used,
            compare.locality,
            compare.kind,
            compare.length,
            compare.order,
          },
        },
        formatting = {
          fields = { 'abbr', 'kind', 'menu' },
          expandable_indicator = true,
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
          -- toggle completion menu https://github.com/hrsh7th/nvim-cmp/issues/429#issuecomment-954121524
          ['<C-e>'] = cmp.mapping({
            i = function()
              if cmp.visible() then
                cmp.abort()
              else
                cmp.complete()
              end
            end,
            c = function()
              if cmp.visible() then
                cmp.close()
              else
                cmp.complete()
              end
            end,
          }),
          ['<C-n>'] = cmp.mapping({
            i = function()
              if cmp.visible() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
              elseif luasnip.in_snippet() and luasnip.choice_active() then -- select next snippet choice node
                luasnip.change_choice(1)
              else
                cmp.complete()
              end
            end,
            c = function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end,
          }),
          ['<C-p>'] = cmp.mapping({
            i = function()
              if cmp.visible() then
                cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
              elseif luasnip.in_snippet() and luasnip.choice_active() then -- select previous choice node
                luasnip.change_choice(-1)
              else
                cmp.complete()
              end
            end,
            c = function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end,
          }),
          -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#confirm-candidate-on-tab-immediately-when-theres-only-one-completion-entry
          ['<C-y>'] = cmp.mapping({
            i = function()
              if luasnip.expandable() then
                luasnip.expand()
              elseif cmp.visible() or #cmp.get_entries() == 1 then
                cmp.confirm({ select = true })
              end
            end,
            c = cmp.mapping.confirm({ select = false }),
          }),
        },
        experimental = {
          ghost_text = true,
        },
        sources = {
          {
            name = 'lazydev',
            group_index = 0, -- set group index to 0 to skip loading LuaLS completions
          },
          { name = 'luasnip' },
          { name = 'nvim_lsp' },
          { name = 'buffer', keyword_length = 3 },
          { name = 'path' },
        },
      })
      local prefix_match = function(entry1, entry2)
        local matches1 = entry1.matches
        local matches2 = entry2.matches
        if not matches1 or not matches2 then
          return nil
        end

        local cursor_pos = vim.api.nvim_win_get_cursor(0)[2]
        local exact_match1 = false
        local exact_match2 = false

        -- Check if any match in entry1 starts at cursor position
        for _, m in ipairs(matches1) do
          if m.input_match_start == cursor_pos then
            exact_match1 = true
            break
          end
        end

        -- Check if any match in entry2 starts at cursor position
        for _, m in ipairs(matches2) do
          if m.input_match_start == cursor_pos then
            exact_match2 = true
            break
          end
        end

        if exact_match1 and not exact_match2 then
          return true
        elseif exact_match2 and not exact_match1 then
          return false
        end

        return nil
      end
      require('cmp').setup.filetype('go', {
        priority_weight = 2,
        comparators = {
          compare.offset,
          compare.exact,
          -- Prioritize exact prefix matches. Other LSPs do that while gopls seems not to. For
          -- example when I am in a struct with fields Literal, AttList, ... and type Li Literal is
          -- not the first item which it should.
          function(entry1, entry2)
            if entry1.source.name ~= 'nvim_lsp' or entry2.source.name ~= 'nvim_lsp' then
              return nil
            end
            return prefix_match(entry1, entry2)
          end,
          compare.scopes,
          compare.score,
          compare.recently_used,
          compare.locality,
          compare.kind,
          compare.length,
          compare.order,
        },
      })

      -- use different sources and mappings on the cmdline
      -- here <Tab> and <CR> are useful to select an item as I don't use them for anything else like
      -- whitespace as in insert mode
      cmp.setup.cmdline({ '/', '?' }, {
        sources = {
          { name = 'buffer' },
        },
      })
      cmp.setup.cmdline(':', {
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
    end,
  },
}

return {
  'L3MON4D3/LuaSnip',
  version = 'v2.*',
  lazy = true,
  config = function()
    local ls = require('luasnip')

    ls.setup({
      history = true,
      enable_autosnippets = true,
      -- the custom filetype 'timesheet' does not suffice as from_pos_or_filetype uses treesitter to
      -- get filetypes which is useful for injected languages like code blocks in markdown. this
      -- means though that treesitter will not return my custom filetype as I need to tell
      -- treesitter to use markdown to parse my custom filetype :joy:
      -- I could not make this work by simply overriding the load_ft_func and looking at the bufname
      -- like I do here. For some reason load_ft_func was called 5 times when opening a timesheet 3
      -- times I got the correct bufname and the last 2 the bufname was "" meaning I could not
      -- deduce that I should load timesheet snippets
      ft_func = function()
        local fts = require('luasnip.extras.filetype_functions').from_pos_or_filetype()
        if not vim.tbl_contains(fts, 'markdown') then
          return fts
        end

        local timesheet_dir = vim.env.HOME .. '/code/dhis2/reporting/timekeeping'
        local buf_dir = vim.api.nvim_buf_get_name(0)
        if vim.fn.match(buf_dir, '^' .. timesheet_dir) ~= -1 then
          table.insert(fts, 'timesheet')
          return fts
        end

        return fts
      end,
      load_ft_func = require('luasnip.extras.filetype_functions').extend_load_ft({
        gitcommit = { 'markdown' },
        markdown = { 'go', 'lua' },
      }),
    })
    ls.log.set_loglevel('error')

    -- lazy load snippets
    local snippet_dir = '~/.config/nvim/luasnip/'
    require('luasnip.loaders.from_lua').lazy_load({ paths = { snippet_dir } })

    -- Remove choice node extmarks when leaving
    -- https://github.com/L3MON4D3/LuaSnip/issues/937
    -- https://github.com/L3MON4D3/LuaSnip/issues/937#issuecomment-2148946914
    local group = vim.api.nvim_create_augroup('UserLuasnip', { clear = true })
    local ns = vim.api.nvim_create_namespace('UserLuasnipNS')
    local function delete_extmarks()
      local extmarks = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})
      for _, extmark in ipairs(extmarks) do
        vim.api.nvim_buf_del_extmark(0, ns, extmark[1])
      end
    end
    vim.api.nvim_create_autocmd('User', {
      group = group,
      pattern = 'LuasnipChoiceNodeEnter',
      callback = function()
        local node = require('luasnip').session.event_node
        local line = node:get_buf_position()[1]
        vim.api.nvim_buf_set_extmark(0, ns, line, -1, {
          end_line = line,
          end_right_gravity = true,
          right_gravity = false,
          virt_text = { { '↻', 'Title' } },
        })
      end,
    })
    vim.api.nvim_create_autocmd('User', {
      group = group,
      pattern = 'LuasnipChoiceNodeLeave',
      callback = delete_extmarks,
    })
    vim.api.nvim_create_autocmd('ModeChanged', {
      group = group,
      pattern = '*[isS\19]*:*[^isS\19]*',
      callback = Debounce(50, function()
        if vim.fn.mode():match('[^isS\19]') then
          delete_extmarks()
        end
      end),
    })

    vim.keymap.set({ 'i', 's' }, '<C-j>', function()
      if ls.choice_active() then
        ls.change_choice(1)
      end
    end, { desc = 'Select next snippet choice node', silent = true })

    vim.keymap.set('n', '<leader>se', function()
      require('luasnip.loaders').edit_snippet_files()
    end, { desc = 'Edit snippets' })

    vim.keymap.set('n', '<leader>sr', function()
      require('luasnip').cleanup()
      require('luasnip.loaders.from_lua').lazy_load({ paths = { snippet_dir } })
    end, { desc = 'Reload snippets' })
  end,
}

return {
  'L3MON4D3/LuaSnip',
  version = 'v2.*',
  lazy = true,
  config = function()
    -- load snippets
    require('luasnip.loaders.from_lua').lazy_load({ paths = '~/.config/nvim/luasnip/' })
    local ls = require('luasnip')
    ls.log.set_loglevel('error')

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

    ls.config.set_config({
      history = true,
      updateevents = 'TextChanged,TextChangedI',
      enable_autosnippets = true,
    })

    -- vim.keymap.set({ 'i', 's' }, '<C-l>', function()
    --   ls.jump(1)
    -- end, { desc = 'Jump to next snippet node', silent = true })
    -- vim.keymap.set({ 'i', 's' }, '<C-h>', function()
    --   ls.jump(-1)
    -- end, { desc = 'Jump to previous snippet node', silent = true })
    --
    -- vim.keymap.set({ 'i', 's' }, '<C-k>', function()
    --   if ls.choice_active() then
    --     ls.change_choice(1)
    --   end
    -- end, { desc = 'Select next snippet choice node', silent = true })

    vim.keymap.set('n', '<leader>se', function()
      require('luasnip.loaders').edit_snippet_files()
    end, { desc = 'Edit snippets' })

    vim.keymap.set('n', '<leader>sr', function()
      require('luasnip').cleanup()
      require('luasnip.loaders.from_lua').lazy_load({ paths = '~/.config/nvim/luasnip/' })
    end, { desc = 'Reload snippets' })
  end,
}

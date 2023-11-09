-- load snippets
require('luasnip.loaders.from_lua').lazy_load({ paths = '~/.config/nvim/luasnip/' })
local types = require('luasnip.util.types')

local ls = require('luasnip')
ls.log.set_loglevel('error')

ls.config.set_config({
  history = true,
  updateevents = 'TextChanged,TextChangedI',
  enable_autosnippets = true,
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { '↻', 'Title' } },
      },
    },
  },
})

-- expand the current item or jump to the next item within the snippet
vim.keymap.set({ 'i', 's' }, '<c-k>', function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })

-- move to the previous item within the snippet
vim.keymap.set({ 'i', 's' }, '<c-j>', function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })

vim.keymap.set({ 'i', 's' }, '<c-l>', function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end, { silent = true })

vim.keymap.set('n', '<leader><leader>s', '<cmd>source ~/code/dotfiles/vim/.config/nvim/lua/my/luasnip/init.lua<CR>')

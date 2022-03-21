-- load snippets from runtimepath, eg. friendly-snippets.
require('luasnip.loaders.from_vscode').lazy_load()

local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require('luasnip.extras.fmt').fmt

ls.config.set_config({
  history = true,
  updateevents = 'TextChanged,TextChangedI',
  enable_autosnippets = true,
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

local prev_day = function(days)
  days = days or 0
  local day = os.time()
  day = day - (days * 60 * 60 * 24)
  return t(os.date('%b, %d', day))
end

local prev_week = function(weeks)
  weeks = weeks or 0
  local week = os.time()
  week = week - (weeks * 60 * 60 * 24 * 7)
  return t(os.date('Week %V', week))
end

-- TODO also load it in git commit window
-- TODO can I load only these snippets only within a specific repo?
-- maybe even move them to that repo and load it on entry
ls.add_snippets('markdown', {
  s(
    'day',--[[ could this display a virtual text also showing the day like Mon, Tue?  ]]
    c(
      1,
      (function()
        local n = {}
        for j = 0, 6 do
          n[j + 1] = prev_day(j)
        end
        return n
      end)()
    )
  ),
  s(
    'week',
    fmt(
      '{}',
      c(1, {
        prev_week(),
        prev_week(1),
        prev_week(2),
      })
    )
  ),
}, {
  key = 'markdown',
})

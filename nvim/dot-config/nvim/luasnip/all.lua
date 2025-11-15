local ls = require('luasnip')
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local c = ls.choice_node
local i = ls.insert_node

return {
  s(
    {
      trig = 'todo',
      name = 'todo',
      desc = 'Create TODO for myself, my team or related to an issue',
    },
    c(1, {
      t('TODO'),
      sn(0, {
        t('TODO('),
        i(1, 'ivo'),
        t(')'),
      }),
    })
  ),
  s({
    trig = 'dhis',
    name = 'dhis2',
    desc = 'DHIS2 acronym correctly spelled',
  }, {
    t('DHIS2'),
  }),
}

local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local c = ls.choice_node
local fmt = require('luasnip.extras.fmt').fmt

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

return {
  s({
    trig = 'cr',
    name = 'Code reviews',
    desc = 'Code reviews',
  }, {
    t('code reviews'),
  }),
  s({
    trig = 'mb',
    name = 'Backend meeting',
    desc = 'Backend meeting',
  }, {
    t('backend meeting'),
  }),
  s({
    trig = 'ms',
    name = 'Tracker standup',
    desc = 'Tracker standup meeting',
  }, {
    t('tracker standup meeting'),
  }),
  s({
    trig = 'mr',
    name = 'Tracker retro',
    desc = 'Tracker retro meeting',
  }, {
    t('tracker retro meeting'),
  }),
  s(
    'day', --[[ could this display a virtual text also showing the day like Mon, Tue?  ]]
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
}

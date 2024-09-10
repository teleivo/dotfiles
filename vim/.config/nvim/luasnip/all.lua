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

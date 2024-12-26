return {
  s(
    { trig = 'code' },
    fmta(
      [[```<>
```
  ]],
      { i(1, 'language') }
    )
  ),
  s({ trig = 'task' }, fmta([[- [<>] <>]], { i(1, ' '), i(2, '') })),
}

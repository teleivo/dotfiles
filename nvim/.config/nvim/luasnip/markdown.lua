return {
  s(
    { trig = 'callout' },
    fmt(
      [[> [!{}] {}
> {}
  ]],
      { i(1, 'NOTE'), i(2, ''), i(3, '') }
    )
  ),
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

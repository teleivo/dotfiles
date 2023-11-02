-- the err should be a dynamic node in case the error is called something else
return {
  s(
    { trig = 'er' },
    fmta(
      [[if <> != nil {
  return <>
}
  ]],
      { i(1, 'err'), c(2, {
        rep(1),
        t('foo'),
      }) }
    )
  ),
}

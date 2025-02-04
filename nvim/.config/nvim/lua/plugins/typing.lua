return {
  'nvzone/typr',
  version = false, -- releases are too old
  dependencies = {
    { 'nvzone/volt', version = false },
  },
  opts = {
    on_attach = function(_)
      require('nvim-autopairs').disable()
    end,
  },
  cmd = {
    'Typr',
    'TyprStats',
  },
}

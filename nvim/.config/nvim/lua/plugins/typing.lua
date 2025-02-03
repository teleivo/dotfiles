return {
  'nvzone/typr',
  dependencies = {
    'nvzone/volt',
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

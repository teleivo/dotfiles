return {
  dev = true,
  dir = '../go',
  ft = {
    'go',
    'gomod',
  },
  config = function()
    require('go.plugin').setup()
  end,
}

return {
  dev = true,
  dir = '../go',
  ft = 'go',
  config = function()
    require('go.plugin').setup()
  end,
}

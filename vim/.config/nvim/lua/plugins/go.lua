return {
  {
    dev = true,
    dir = '../go',
    ft = {
      'go',
    },
    config = function()
      require('go.go_plugin').setup()
    end,
  },
  {
    dev = true,
    dir = '../go',
    ft = {
      'gomod',
    },
    config = function()
      require('go.gomod_plugin').setup()
    end,
  },
}

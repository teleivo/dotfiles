return {
  {
    dev = true,
    dir = '~/code/dotfiles/vim/.config/nvim/lua/go/plugins/go',
    ft = {
      'go',
    },
    config = function()
      require('go.plugins.go').setup()
    end,
  },
  {
    dev = true,
    dir = '~/code/dotfiles/vim/.config/nvim/lua/go/plugins/gomod',
    ft = {
      'gomod',
    },
    config = function()
      require('go.plugins.gomod').setup()
    end,
  },
}

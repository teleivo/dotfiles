return {
  {
    -- TODO move that into ftplugin put it into go itself or gomod?
    dev = true,
    dir = '~/code/dotfiles/vim/.config/nvim/lua/my-go/plugins/gomod',
    ft = {
      'gomod',
    },
    config = function()
      require('my-go.plugins.gomod').setup()
    end,
  },
}

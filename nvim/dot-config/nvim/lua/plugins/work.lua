return {
  dir = vim.env.DOTFILES .. '/nvim/dot-config/nvim/lua/my-work',
  cond = function()
    -- only load in DHIS2 subdirs
    return vim.startswith(vim.fn.getcwd(), vim.env.HOME .. '/code/dhis2')
  end,
  config = function()
    -- I don't follow the more involved lazy.nvim plugin spec which is why it cannot find my plugin.
    -- I am thus loading it myself.
    require('my-work')
  end,
}

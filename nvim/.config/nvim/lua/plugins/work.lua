return {
  dir = vim.env.DOTFILES .. '/nvim/.config/nvim/lua/my-work',
  cond = function()
    return vim.startswith(vim.fn.getcwd(), vim.env.HOME .. '/code/dhis2')
  end,
}

vim.opt_local.comments = { 'b:*', 'b:-', 'b:+', 'b:1.', 'n:>' }
vim.opt_local.formatoptions:append('r')
vim.opt_local.formatoptions:append('o')
vim.keymap.set('i', '<cr>', function()
  -- delete empty list item
  if
    vim.api.nvim_get_current_line():match('^%s*[*-]%s*$')
    or vim.api.nvim_get_current_line():match('^%s*%d+%.%s*$')
  then
    vim.api.nvim_set_current_line('')
    return
  end

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', true)
end, { buffer = true, desc = 'Enter (removing empty list item)' })

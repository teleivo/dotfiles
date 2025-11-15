vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.cl',
  callback = function()
    vim.bo.filetype = 'cool'
  end,
})

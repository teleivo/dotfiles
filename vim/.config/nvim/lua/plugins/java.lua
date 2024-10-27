return {
  {
    'mfussenegger/nvim-jdtls',
    ft = 'java',
    dependencies = 'hrsh7th/cmp-nvim-lsp',
    config = function()
      local group = vim.api.nvim_create_augroup('my_java', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'java',
        callback = function()
          require('my-java').start_jdt()
        end,
        group = group,
      })
    end,
  },
}

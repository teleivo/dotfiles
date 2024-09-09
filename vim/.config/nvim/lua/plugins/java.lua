return {
  {
    'mfussenegger/nvim-jdtls',
    ft = 'java',
    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'java',
        callback = function()
          require('java').start_jdt()
        end,
      })
    end,
  },
}

return {
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      require('dapui').setup()
    end,
  },
  {
    'leoluz/nvim-dap-go',
    dependencies = { 'mfussenegger/nvim-dap' },
    config = function()
      require('dap-go').setup()
    end,
    ft = { 'go' },
    keys = {
      {
        '<leader>dt',
        function()
          require('dap-go').debug_test()
        end,
      },
    },
  },
  {
    'mfussenegger/nvim-dap',
    keys = {
      {
        '<leader>db',
        function()
          return require('dap').toggle_breakpoint()
        end,
      },
      {
        '<leader>dc',
        function()
          return require('dap').continue()
        end,
      },
      {
        '<leader>ds',
        function()
          return require('dap').step_over()
        end,
      },
      -- TODO why is that one not working?
      {
        '<leader>di',
        function()
          return require('dap').step_into()
        end,
      },
      {
        '<leader>do',
        function()
          return require('dap').step_out()
        end,
      },
      {
        '<leader>dr',
        function()
          return require('dap').repl.open()
        end,
      },
      {
        '<leader>dl',
        function()
          return require('dap').run_last()
        end,
      },
    },
  },
}

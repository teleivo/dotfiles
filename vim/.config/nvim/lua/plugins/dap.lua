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
        desc = 'Toggle debugger breakpoint',
      },
      {
        '<leader>dc',
        function()
          return require('dap').continue()
        end,
        desc = 'Continue debugger execution',
      },
      {
        '<leader>ds',
        function()
          return require('dap').step_over()
        end,
        desc = 'Step over current position in debugger',
      },
      -- TODO why is that one not working?
      {
        '<leader>di',
        function()
          return require('dap').step_into()
        end,
        desc = 'Step into current function or method in debugger',
      },
      {
        '<leader>do',
        function()
          return require('dap').step_out()
        end,
        desc = 'Step out of current function or method in debugger',
      },
      {
        '<leader>dr',
        function()
          return require('dap').repl.open()
        end,
        desc = 'Open debugger repl',
      },
      {
        '<leader>dl',
        function()
          return require('dap').run_last()
        end,
        desc = 'Re-runs the last debug adapter',
      },
    },
  },
}

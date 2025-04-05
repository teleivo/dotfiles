return {
  'yetone/avante.nvim',
  -- only load avante when needed, not automatically at startup
  cmd = {
    'AvanteAsk',
    'AvanteBuild',
    'AvanteChat',
    'AvanteEdit',
    'AvanteFocus',
    'AvanteRefresh',
    'AvanteSwitchProvider',
    'AvanteShowRepoMap',
    'AvanteToggle',
  },
  -- https://github.com/yetone/avante.nvim/wiki#keymaps-and-api-i-guess
  keys = function(_, keys)
    ---@type avante.Config
    local opts = require('lazy.core.plugin').values(
      require('lazy.core.config').spec.plugins['avante.nvim'],
      'opts',
      false
    )

    local mappings = {
      {
        '<leader>aa',
        function()
          require('avante.api').ask()
        end,
        desc = 'avante: ask',
        mode = { 'n', 'v' },
      },
      {
        '<leader>ar',
        function()
          require('avante.api').refresh()
        end,
        desc = 'avante: refresh',
        mode = 'v',
      },
      {
        '<leader>ae',
        function()
          require('avante.api').edit()
        end,
        desc = 'avante: edit',
        mode = { 'n', 'v' },
      },
    }
    mappings = vim.tbl_filter(function(m)
      return m[1] and #m[1] > 0
    end, mappings)
    return vim.list_extend(mappings, keys)
  end,
  ---@module 'avante'
  ---@class avante.Config
  opts = {
    provider = 'copilot',
    auto_suggestions_provider = nil,
    copilot = { model = 'claude-3.7-sonnet' },
    web_search_engine = {
      provider = nil,
    },
    disabled_tools = { 'python', 'web_search' },
    custom_tools = {
      -- nlua Lua script that lets you use Neovim as a Lua interpreter.
      -- https://github.com/mfussenegger/nlua
      {
        name = 'lua',
        description = "Execute Lua inside Neovim with access to Neovim's Lua modules and environment",
        command = 'nlua -e',
        param = {
          type = 'table',
          fields = {
            {
              name = 'chunk',
              description = 'Lua chunk to be executed',
              type = 'string',
              optional = false,
            },
          },
        },
        returns = {
          {
            name = 'result',
            description = 'Printed Lua expressions and return value of Lua chunk',
            type = 'string',
          },
          {
            name = 'error',
            description = 'Error message if the execution was not successful',
            type = 'string',
            optional = true,
          },
        },
        func = function(params, on_log)
          -- maybe use on_complete (3rd param) in case I get in trouble with some executions as the
          -- model does not print what went wrong by default
          local chunk = params.chunk
          if not chunk then
            on_log('no Lua chunk given to execute')
            return
          end

          on_log('executing Lua chunk `' .. chunk .. '`')
          return vim.fn.system(string.format("nlua -e '%s'", chunk))
        end,
      },
    },
    hints = {
      enabled = false,
    },
    windows = {
      width = 40, -- % based on available width
      sidebar_header = {
        enabled = false,
      },
    },
    file_selector = {
      provider = 'telescope',
    },
  },
  build = 'make',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
    'saghen/blink.cmp',
    {
      'zbirenbaum/copilot.lua',
      opts = {
        suggestion = { enabled = false },
        panel = { enabled = false },
      },
    },
    {
      'MeanderingProgrammer/render-markdown.nvim',
      dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
      ft = { 'Avante' },
      ---@module 'render-markdown'
      ---@type render.md.UserConfig
      opts = {
        sign = { enabled = false },
        checkbox = {
          unchecked = {
            icon = '',
            highlight = '@comment.warning',
          },
          checked = {
            icon = '',
            highlight = '@comment.note',
          },
          custom = {
            todo = {
              raw = '[-]',
              rendered = '󰥔',
              highlight = '@comment.todo',
            },
          },
        },
        file_types = { 'Avante' },
        log_level = 'error',
      },
    },
  },
}

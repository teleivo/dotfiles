return {
  {
    'rest-nvim/rest.nvim',
    dependencies = {
      {
        'luarocks.nvim',
      },
      {
        'vhyrro/luarocks.nvim',
        opts = {
          rocks = { 'lua-curl', 'nvim-nio', 'mimetypes', 'xml2lua', 'fidget.nvim' },
        },
      },
    },
    ft = 'http',
    keys = {
      { '<leader>rr', ':Rest run<CR>', desc = 'Run HTTP request using rest-nvim' },
      { '<leader>rl', ':Rest last<CR>', desc = 'Re-run last HTTP request using rest-nvim' },
      {
        '<leader>re',
        ':Rest env select<CR>',
        desc = 'Select .env file for running HTTP request using rest-nvim',
      },
    },
    config = function()
      vim.g.rest_nvim = {
        env = {
          find = function()
            local config = require('rest-nvim.config')
            local start = vim.api.nvim_buf_get_name(0)
            local git_dir = vim.fs.root(0, '.git')
            -- vim.fs.find stop is exclusive meaning the stop dir will not be searched
            local stop = vim.fs.dirname(git_dir)
            return vim.fs.find(function(name)
              return name:match(config.env.pattern)
            end, {
              limit = math.huge,
              type = 'file',
              path = start,
              stop = stop,
              upward = true,
            })
          end,
        },
        request = {
          hooks = {
            set_content_type = false,
          },
        },
        clients = {
          curl = {
            statistics = {
              { id = 'time_namelookup', winbar = false, title = 'Time taken until name resolved' },
              {
                id = 'time_connect',
                winbar = false,
                title = 'Time taken until TCP connection established',
              },
              {
                id = 'time_appconnect',
                winbar = false,
                title = 'Time taken until SSL/SSH/etc connection established',
              },
              { id = 'time_total', winbar = 'total', title = 'Time taken in total (total)' },
              { id = 'size_upload', winbar = false, title = 'Size of request body' },
              { id = 'size_request', winbar = 'up', title = 'Total request size (up)' },
              { id = 'size_download', winbar = 'down', title = 'Download size (down)' },
            },
          },
        },
        -- _log_level = vim.log.levels.DEBUG, -- uncomment for debugging
        custom_dynamic_variables = {
          ['dhis2Uid'] = function()
            return require('my-dhis2').uid()
          end,
        },
      }
    end,
  },
}

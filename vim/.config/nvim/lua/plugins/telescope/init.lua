return {
  {
    'nvim-telescope/telescope.nvim',
    lazy = false,
    version = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-dap.nvim',
      'cljoly/telescope-repo.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        enabled = vim.fn.executable('make') == 1,
      },
    },
    config = function()
      local actions = require('telescope.actions')
      local opts = {
        defaults = {
          mappings = {
            i = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
            },
          },
          path_display = function(_, path)
            local tail = require('telescope.utils').path_tail(path)
            return string.format('%s (%s)', tail, path)
          end,
          winblend = 0,
          layout_strategy = 'horizontal',
          layout_config = {
            width = 0.95,
            height = 0.85,
            prompt_position = 'top',
            horizontal = {
              preview_width = function(_, cols, _)
                if cols > 200 then
                  return math.floor(cols * 0.4)
                else
                  return math.floor(cols * 0.6)
                end
              end,
            },
            vertical = {
              width = 0.9,
              height = 0.95,
              preview_height = 0.5,
            },
            flex = {
              horizontal = {
                preview_width = 0.9,
              },
            },
          },
          selection_strategy = 'reset',
          sorting_strategy = 'ascending',
          scroll_strategy = 'cycle',
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
          },
        },
      }
      require('telescope').setup(opts)

      -- TODO requires mfusseneger/nvim-dap require('telescope').load_extension('dap')
      -- To get fzf loaded and working with telescope
      require('telescope').load_extension('fzf')
      require('telescope').load_extension('repo')
    end,
    keys = {
      {
        '<C-p>',
        function()
          require('telescope.builtin').builtin({ include_extensions = true })
        end,
      },
      {
        '<leader>fb',
        function()
          require('telescope.builtin').buffers()
        end,
      },
      {
        '<leader>fe',
        function()
          require('telescope.builtin').diagnostics()
        end,
      },
      {
        '<leader>ff',
        function()
          require('plugins.telescope.functions').project_find_files()
        end,
      },
      {
        '<leader>fd',
        function()
          require('plugins.telescope.functions').dotfiles_find()
        end,
      },
      {
        '<leader>fg',
        function()
          require('plugins.telescope.functions').project_live_grep()
        end,
      },
      {
        '<leader>fh',
        function()
          require('telescope.builtin').help_tags()
        end,
      },
      {
        '<leader>fo',
        function()
          require('telescope.builtin').oldfiles()
        end,
      },
      {
        '<leader>fr',
        function()
          require('telescope.builtin').resume()
        end,
      },
    },
  },
}

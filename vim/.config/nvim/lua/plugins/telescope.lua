-- TODO why do I have to type i in picker Buffer for example?
return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    version = false, -- telescope did only one release, so use HEAD for now
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
    config = function(_, opts)
      require('telescope').setup(opts)
      -- To get fzf loaded and working with telescope
      -- TODO requires mfusseneger/nvim-dap require('telescope').load_extension('dap')
      require('telescope').load_extension('fzf')
      require('telescope').load_extension('repo')
    end,
    opts = {
      defaults = {
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
    },
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
          require('my.telescope.functions').project_files()
        end,
      },
      --{'<leader>fd', function() require('my.telescope.functions').dotfiles() end },
      {
        '<leader>fg',
        function()
          require('telescope.builtin').live_grep()
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
-- TODO Integrate this
-- -- open file finder only if neovim is started without arguments
-- vim.api.nvim_create_autocmd('VimEnter', {
--   callback = function()
--     if vim.tbl_count(vim.v.argv) == 1 then
--       require('my.telescope.functions').project_files()
--     end
--   end,
--   once = true,
--   group = group,
-- })

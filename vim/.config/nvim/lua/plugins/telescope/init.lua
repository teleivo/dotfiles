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
      'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
      -- set log level for logs in ~/.cache/nvim/telescope.log
      -- local log = require('telescope.log')
      -- log.level = 'trace'

      local actions = require('telescope.actions')
      local transform_mod = require('telescope.actions.mt').transform_mod
      local get_git_project_root = require('git').get_git_root

      local custom_actions = {}
      --- Redraw the cursor a few line of the top so its in a comfortable position. Can be used
      --- after selecting a file to edit. You can just map `actions.select_default + actions.center`
      custom_actions.top = function()
        local old_scrolloff = vim.o.scrolloff
        vim.o.scrolloff = 6 -- position cursor n lines below top
        vim.cmd(':normal! zt')
        vim.o.scrolloff = old_scrolloff
      end
      --- Set the tab current directory of the current buffer. In my workflow tabs are used for
      --- projects (git repos). So when I open up a new project I want the tabs current directory to
      --- be rooted in that projects directory. This makes things like opening files, committing
      --- changes in another project way easier.
      custom_actions.tcd = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local file = vim.api.nvim_buf_get_name(bufnr)
        local project_root = get_git_project_root(file)
        vim.cmd(string.format('tcd %s', vim.fn.fnameescape(project_root)))
      end
      custom_actions = transform_mod(custom_actions)

      local opts = {
        defaults = {
          mappings = {
            i = {
              ['<CR>'] = actions.select_default + custom_actions.top,
              ['<C-x>'] = actions.select_horizontal + custom_actions.top,
              ['<C-v>'] = actions.select_vertical + custom_actions.top,
              ['<C-t>'] = actions.select_tab + custom_actions.top + custom_actions.tcd,
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-f>'] = actions.results_scrolling_down,
              ['<C-b>'] = actions.results_scrolling_up,
              ['<C-/>'] = require('telescope.actions.layout').toggle_preview,
              ['<C-_>'] = require('telescope.actions.layout').toggle_preview,
              ['<C-h>'] = actions.which_key,
            },
          },
          path_display = function(_, path)
            local tail = require('telescope.utils').path_tail(path)
            return string.format('%s (%s)', tail, path)
          end,
          selection_caret = '▌ ',
          multi_icon = '┃',
          winblend = 0,
          dynamic_preview_title = true,
          preview = {
            filesize_limit = 2, -- MB
            hide_on_startup = true,
          },
          layout_strategy = 'horizontal',
          layout_config = {
            width = 0.95,
            height = 0.85,
            prompt_position = 'top',
            horizontal = {
              preview_width = function(_, cols, _)
                if cols >= 200 then
                  return 120
                end

                return 100
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
        pickers = {
          find_files = {
            -- so I find the current_issue.md in my notes which is linked to a markdown
            find_command = { 'rg', '--files', '--follow' },
          },
          lsp_document_symbols = {
            fname_width = 0, -- as results are for the currently opened file
            symbol_width = 50, -- to leave room for the symbol_type as well
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
          },
          repo = {
            list = {
              fd_opts = {
                '--no-ignore', -- don't use fdignore which ignores .git, otherwise no repo is found
                '--exclude',
                'target', -- maven projects cloning git repos
                '--exclude',
                'tmp', -- dhis2 docs builder cloning docs repos
                '--exclude',
                '.terraform', -- terraform modules
                '--exclude',
                '3rd', -- 3rd party libraries used by lua_ls
              },
              search_dirs = {
                '~/.local/share/nvim/lazy',
                '~/code',
              },
            },
            cached_list = { -- list (fd) is faster than cached_lits, not sure if I can do something to speed this up
              file_ignore_patterns = {
                '/Documents/',
                '/%.cache/',
                '/%.cargo/',
              },
            },
          },
        },
      }
      require('telescope').setup(opts)

      -- TODO requires mfusseneger/nvim-dap require('telescope').load_extension('dap')
      -- To get fzf loaded and working with telescope
      require('telescope').load_extension('fzf')
      require('telescope').load_extension('repo')
      require('telescope').load_extension('ui-select')
    end,
    keys = {
      {
        '<leader>fc',
        function()
          require('telescope.builtin').builtin({ include_extensions = true })
        end,
        desc = 'Search telescope builtin pickers',
      },
      {
        '<leader>fb',
        function()
          require('telescope.builtin').buffers()
        end,
        desc = 'Search buffers',
      },
      {
        '<leader>fe',
        function()
          require('telescope.builtin').diagnostics()
        end,
        desc = 'Search diagnostics',
      },
      {
        '<leader>ff',
        function()
          require('plugins.telescope.functions').project_find_files()
        end,
        desc = 'Search files in project',
      },
      {
        '<leader>fd',
        function()
          require('plugins.telescope.functions').dotfiles_find()
        end,
        desc = 'Search files in dotfiles',
      },
      {
        '<leader>fg',
        function()
          require('plugins.telescope.functions').project_live_grep()
        end,
        desc = 'Live grep in project',
      },
      {
        '<leader>fh',
        function()
          require('telescope.builtin').help_tags()
        end,
        desc = 'Search for help',
      },
      {
        '<leader>fo',
        function()
          require('telescope.builtin').oldfiles()
        end,
        desc = 'Search for old files',
      },
      {
        '<leader>fr',
        function()
          require('telescope.builtin').resume()
        end,
        desc = 'Resume last telescope search',
      },
      {
        '<leader>fp',
        function()
          require('telescope').extensions.repo.list()
        end,
        desc = 'Search projects',
      },
    },
  },
}

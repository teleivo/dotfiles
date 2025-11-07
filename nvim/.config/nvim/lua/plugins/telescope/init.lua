return {
  {
    'nvim-telescope/telescope.nvim',
    lazy = false,
    version = 'v0.1.9',
    dependencies = {
      { 'nvim-lua/plenary.nvim', version = false },
      { 'cljoly/telescope-repo.nvim', version = false },
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        enabled = vim.fn.executable('make') == 1,
        version = false,
      },
      { 'nvim-telescope/telescope-ui-select.nvim', version = false },
    },
    config = function()
      -- set log level for logs in ~/.cache/nvim/telescope.log
      -- local log = require('telescope.log')
      -- log.level = 'trace'

      local actions = require('telescope.actions')
      local actions_layout = require('telescope.actions.layout')
      local transform_mod = require('telescope.actions.mt').transform_mod
      local get_git_project_root = require('git').get_git_root

      local custom_actions = {
        --- Redraw the cursor a few line of the top so its in a comfortable position. Can be used
        --- after selecting a file to edit. You can just map `actions.select_default + actions.center`
        top_with_offset = function()
          local old_scrolloff = vim.o.scrolloff
          vim.o.scrolloff = 6 -- position cursor n lines below top
          vim.cmd(':normal! zt')
          vim.o.scrolloff = old_scrolloff
        end,
        -- Jump to the line of the first top level declaration node using treesitter.
        top_level_declaration = function()
          require('my-treesitter').top_level_declaration()
        end,
        --- Set the tab current directory of the current buffer. In my workflow tabs are used for
        --- projects (git repos). So when I open up a new project I want the tabs current directory to
        --- be rooted in that projects directory. This makes things like opening files, committing
        --- changes in another project way easier.
        tcd = function()
          local bufnr = vim.api.nvim_get_current_buf()
          local file = vim.api.nvim_buf_get_name(bufnr)
          local project_root = get_git_project_root(file)
          vim.cmd(string.format('tcd %s', vim.fn.fnameescape(project_root)))
        end,
      }
      custom_actions = transform_mod(custom_actions)

      local opts = {
        defaults = {
          mappings = {
            i = {
              ['<CR>'] = actions.select_default + custom_actions.top_with_offset,
              ['<C-x>'] = actions.select_horizontal + custom_actions.top_with_offset,
              ['<C-v>'] = actions.select_vertical + custom_actions.top_with_offset,
              ['<C-t>'] = actions.select_tab + custom_actions.top_with_offset + custom_actions.tcd,
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-f>'] = actions.results_scrolling_down,
              ['<C-b>'] = actions.results_scrolling_up,
              ['<C-/>'] = actions_layout.toggle_preview,
              ['<C-_>'] = actions_layout.toggle_preview,
              ['<C-h>'] = actions.which_key,
              ['<Down>'] = actions.cycle_history_next,
              ['<Up>'] = actions.cycle_history_prev,
            },
          },
          path_display = {
            filename_first = {
              reverse_directories = true,
            },
          },
          selection_caret = '▌ ',
          multi_icon = '┃',
          winblend = 0,
          dynamic_preview_title = true,
          preview = {
            filesize_limit = 2, -- MB
            hide_on_startup = true,
            filesize_hook = function(filepath, bufnr, opts)
              -- local path = require('plenary.path'):new(filepath)
              -- -- opts exposes winid
              -- local height = vim.api.nvim_win_get_height(opts.winid)
              -- local lines = vim.split(path:head(height), '[\r]?\n')
              -- vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
              -- TODO do I need to pass the bufnr in?
              require('my-treesitter').top_level_declaration()
            end,
          },
          layout_strategy = 'horizontal',
          layout_config = {
            prompt_position = 'top',
            horizontal = {
              preview_width = function(_, cols)
                if cols < 120 then
                  return math.floor(cols * 0.4)
                elseif cols < 150 then
                  return 80
                else
                  return 120
                end
              end,
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
          buffers = {
            theme = 'ivy',
            results_title = false,
          },
          find_files = {
            theme = 'ivy',
            results_title = false,
            -- so I find the current_issue.md in my notes which is linked to a markdown
            find_command = { 'rg', '--files', '--follow' },
            mappings = {
              i = {
                ['<CR>'] = actions.select_default
                  + custom_actions.top_level_declaration
                  + custom_actions.top_with_offset,
                ['<C-x>'] = actions.select_horizontal
                  + custom_actions.top_level_declaration
                  + custom_actions.top_with_offset,
                ['<C-v>'] = actions.select_vertical
                  + custom_actions.top_level_declaration
                  + custom_actions.top_with_offset,
                ['<C-t>'] = actions.select_tab
                  + custom_actions.top_level_declaration
                  + custom_actions.top_with_offset
                  + custom_actions.tcd,
              },
            },
          },
          lsp_definitions = {
            reuse_win = true,
          },
          lsp_document_symbols = {
            fname_width = 0, -- as results are for the currently opened file
            symbol_width = 50, -- to leave room for the symbol_type as well
          },
          lsp_implementations = {
            reuse_win = true,
          },
          lsp_references = {
            reuse_win = true,
            include_declaration = false,
          },
          lsp_type_definitions = {
            reuse_win = true,
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

      -- To get fzf loaded and working with telescope
      require('telescope').load_extension('fzf')
      require('telescope').load_extension('repo')
      require('telescope').load_extension('ui-select')

      -- wrap lines in previewer
      vim.api.nvim_create_autocmd('User', {
        pattern = 'TelescopePreviewerLoaded',
        callback = function()
          vim.wo.wrap = true
        end,
      })
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
        '<leader>fq',
        function()
          require('telescope.builtin').quickfixhistory()
        end,
        desc = 'Search quickfix history',
      },
      {
        '<leader>ff',
        function()
          require('plugins.telescope.functions').project_find_files()
        end,
        desc = 'Search files in project',
        mode = 'n',
      },
      {
        '<leader>ff',
        -- Use the visually selected trimmed text as the input. Only the first line is used if more
        -- than one are selected.
        function()
          local default_text
          local selection =
            vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('v'), { type = vim.fn.mode() })
          if selection and #selection > 0 then
            default_text = selection[1] and vim.trim(selection[1])
          end
          require('plugins.telescope.functions').project_find_files({ default_text = default_text })
        end,
        desc = 'Search files in project using the visual selection (max 1 line)',
        mode = 'v',
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
        mode = 'n',
      },
      {
        '<leader>fg',
        -- Use the visually selected trimmed text as the input to the project_live_grep. Only the
        -- first line is used if more than one are selected.
        function()
          local default_text
          local selection =
            vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('v'), { type = vim.fn.mode() })
          if selection and #selection > 0 then
            default_text = selection[1] and vim.trim(selection[1])
            local filetype = vim.api.nvim_get_option_value('filetype', { buf = 0 })
            default_text = default_text .. (filetype ~= '' and '  *.' .. filetype or '')
          end
          require('plugins.telescope.functions').project_live_grep({ default_text = default_text })
        end,
        desc = 'Live grep in project using the visual selection (max 1 line)',
        mode = 'v',
      },
      {
        '<leader>fh',
        function()
          require('telescope.builtin').help_tags()
        end,
        desc = 'Search for help',
        mode = 'n',
      },
      {
        '<leader>fh',
        function()
          local default_text
          local selection =
            vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('v'), { type = vim.fn.mode() })
          if selection and #selection > 0 then
            default_text = selection[1] and vim.trim(selection[1])
          end
          require('telescope.builtin').help_tags({ default_text = default_text })
        end,
        desc = 'Search for help using the visual selection (max 1 line)',
        mode = 'v',
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
          -- cannot configure this globally only for this extension
          -- https://github.com/cljoly/telescope-repo.nvim/issues/44#issuecomment-1334520216
          -- for some reason the option passed via lua have no effect
          -- require('telescope').extensions.repo.list({
          --   theme = 'ivy',
          --   results_title = false,
          -- })
          -- which is why I am falling back to calling a vim command
          vim.cmd('Telescope repo list theme=ivy results_title=false')
        end,
        desc = 'Search projects',
      },
    },
  },
}

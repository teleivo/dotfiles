return {
  {
    'nvim-treesitter/nvim-treesitter',
    version = false, -- last release is way too old
    build = ':TSUpdate',
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
      },
    },
    init = function()
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end,
    config = function()
      vim.o.foldminlines = 5 -- don't close tiny folds
      vim.o.foldcolumn = 'auto:2'

      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'bash',
          'c',
          'dockerfile',
          'dot',
          'go',
          'gomod',
          'gowork',
          'groovy',
          'hcl',
          'html',
          'http',
          'java',
          'javascript',
          'json',
          'lua',
          'luadoc',
          'make',
          'markdown',
          'markdown_inline',
          'query',
          'sql',
          'toml',
          'typescript',
          'vim',
          'xml',
          'yaml',
        },
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = 'gnn',
            node_incremental = 'gnn',
            scope_incremental = false,
            node_decremental = 'gnp',
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- capture groups defined in textobjects.scm
              ['af'] = { query = '@function.outer', desc = 'Select outer part of a function' },
              ['if'] = { query = '@function.inner', desc = 'Select inner part of a function' },
              ['ac'] = { query = '@conditional.outer', desc = 'Select outer part of a conditional' },
              ['ic'] = { query = '@conditional.inner', desc = 'Select inner part of a conditional' },
              -- using k as I prefer c for conditionals and klass is often used in Java anyway as
              -- class is reserved
              ['ak'] = {
                query = '@class.outer',
                desc = 'Select outer part of a class or struct/interface in Go',
              },
              ['ik'] = {
                query = '@class.inner',
                desc = 'Select inner part of a class or struct/interface in Go',
              },
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- set jumps in the jumplist
            goto_next_start = {
              [']f'] = '@function.outer',
              [']k'] = '@class.outer',
            },
            goto_next_end = {
              [']F'] = '@function.outer',
              [']K'] = '@class.outer',
            },
            goto_previous_start = {
              ['[f'] = '@function.outer',
              ['[k'] = '@class.outer',
            },
            goto_previous_end = {
              ['[F'] = '@function.outer',
              ['[K'] = '@class.outer',
            },
          },
        },
        playground = {
          enable = true,
          disable = {},
          updatetime = 25,
          persist_queries = true,
          keybindings = {
            toggle_query_editor = 'o',
            toggle_hl_groups = 'i',
            toggle_injected_languages = 't',
            toggle_anonymous_nodes = 'a',
            toggle_language_display = 'I',
            focus_language = 'f',
            unfocus_language = 'F',
            update = 'R',
            goto_node = '<cr>',
            show_help = '?',
          },
        },
        query_linter = {
          enable = true,
          use_virtual_text = true,
          lint_events = { 'BufWrite', 'CursorHold' },
        },
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {
      separator = '┄',
      multiline_threshold = 10,
    },
  },
}

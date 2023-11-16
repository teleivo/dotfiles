return {
  {
    'nvim-treesitter/nvim-treesitter',
    version = false, -- last release is way too old
    build = ':TSUpdate',
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
      },
      {
        'nvim-treesitter/playground',
      },
    },
    config = function()
      local treesitter = require('nvim-treesitter.configs')

      ---@type TSConfig
      ---@diagnostic disable-next-line: missing-fields
      treesitter.setup({
        ensure_installed = {
          'bash',
          'c',
          'dockerfile',
          'go',
          'gomod',
          'gowork',
          'hcl',
          'html',
          'java',
          'javascript',
          'json',
          'lua',
          'luadoc',
          'make',
          'markdown',
          'markdown_inline',
          'query',
          'typescript',
          'vim',
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
            init_selection = 'gh',
            node_incremental = 'gh',
            scope_incremental = 'gH',
            node_decremental = 'gl',
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@conditional.outer',
              ['ic'] = '@conditional.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']m'] = '@function.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
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
}

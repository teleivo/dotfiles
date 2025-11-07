return {
  {
    'nvim-treesitter/nvim-treesitter',
    commit = '310f0925', -- last commit before configs.lua was removed
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
      vim.o.foldminlines = 2 -- don't close tiny folds
      vim.o.foldenable = false

      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'bash',
          'c',
          'diff',
          'dockerfile',
          'dot',
          'git_config',
          'git_rebase',
          'gitattributes',
          'gitcommit',
          'gitignore',
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
            -- using symmetrical keys left|right on my keyboard. this does not work inside of tmux
            -- as <C-I> and enter cannot be distinguished
            init_selection = '<tab>',
            node_incremental = '<tab>',
            scope_incremental = false,
            node_decremental = '<enter>',
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
      max_lines = 5,
    },
  },
}

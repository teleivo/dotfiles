return {
  {
    'nvim-treesitter/nvim-treesitter',
    -- as of 2026-03-31 the main branch has no tags to pin to
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    config = function()
      require('nvim-treesitter').setup({})

      require('nvim-treesitter').install({
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
        'rust',
        'sql',
        'toml',
        'typescript',
        'vim',
        'xml',
        'yaml',
      })

      -- Highlighting (built-in in Neovim 0.12)
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })

      -- Indentation
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      -- Folds
      vim.o.foldminlines = 2
      vim.o.foldenable = false
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

      -- Incremental selection using built-in treesitter select
      local select = require('vim.treesitter._select')
      vim.keymap.set('n', '<tab>', function()
        select.select_parent(1)
      end, { desc = 'Init/increment treesitter selection' })
      vim.keymap.set('x', '<tab>', function()
        select.select_parent(1)
      end, { desc = 'Increment treesitter selection' })
      vim.keymap.set('x', '<enter>', function()
        select.select_child(1)
      end, { desc = 'Decrement treesitter selection' })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    -- as of 2026-03-31 the main branch has no tags to pin to
    branch = 'main',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      local textobjects = require('nvim-treesitter-textobjects')
      textobjects.setup({
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      })

      local select_textobject = require('nvim-treesitter-textobjects.select').select_textobject
      local move = require('nvim-treesitter-textobjects.move')

      -- Text object selection
      -- capture groups defined in textobjects.scm
      vim.keymap.set({ 'x', 'o' }, 'af', function()
        select_textobject('@function.outer', 'textobjects')
      end, { desc = 'Select outer part of a function' })
      vim.keymap.set({ 'x', 'o' }, 'if', function()
        select_textobject('@function.inner', 'textobjects')
      end, { desc = 'Select inner part of a function' })
      vim.keymap.set({ 'x', 'o' }, 'ac', function()
        select_textobject('@conditional.outer', 'textobjects')
      end, { desc = 'Select outer part of a conditional' })
      vim.keymap.set({ 'x', 'o' }, 'ic', function()
        select_textobject('@conditional.inner', 'textobjects')
      end, { desc = 'Select inner part of a conditional' })
      -- using k as I prefer c for conditionals and klass is often used in Java anyway as
      -- class is reserved
      vim.keymap.set({ 'x', 'o' }, 'ak', function()
        select_textobject('@class.outer', 'textobjects')
      end, { desc = 'Select outer part of a class or struct/interface in Go' })
      vim.keymap.set({ 'x', 'o' }, 'ik', function()
        select_textobject('@class.inner', 'textobjects')
      end, { desc = 'Select inner part of a class or struct/interface in Go' })

      -- Movement
      vim.keymap.set({ 'n', 'x', 'o' }, ']f', function()
        move.goto_next_start('@function.outer', 'textobjects')
      end, { desc = 'Next function start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']k', function()
        move.goto_next_start('@class.outer', 'textobjects')
      end, { desc = 'Next class start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']F', function()
        move.goto_next_end('@function.outer', 'textobjects')
      end, { desc = 'Next function end' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']K', function()
        move.goto_next_end('@class.outer', 'textobjects')
      end, { desc = 'Next class end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[f', function()
        move.goto_previous_start('@function.outer', 'textobjects')
      end, { desc = 'Previous function start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[k', function()
        move.goto_previous_start('@class.outer', 'textobjects')
      end, { desc = 'Previous class start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[F', function()
        move.goto_previous_end('@function.outer', 'textobjects')
      end, { desc = 'Previous function end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[K', function()
        move.goto_previous_end('@class.outer', 'textobjects')
      end, { desc = 'Previous class end' })
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

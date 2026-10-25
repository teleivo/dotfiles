return {
  'mfussenegger/nvim-lint',
  version = false, -- releases are too old
  opts = {
    events = { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
    linters_by_ft = {
      -- ['*'] = { 'codespell' },
      go = { 'golangcilint' },
      -- lua = { 'luacheck' },
      sh = { 'shellcheck' },
    },
    linters = {
      -- nvim-lint decides whether to lint the package dir or only the file by running 'go env GOMOD'
      -- once in the cwd of nvim. This breaks linting files outside of that module like Go scratch
      -- buffers in /tmp. Find the module per buffer instead and run golangci-lint from its root.
      golangcilint = function()
        local linter = require('lint.linters.golangcilint')
        -- drop the trailing function nvim-lint uses to compute the path to lint
        local args = vim.tbl_filter(function(arg)
          return type(arg) ~= 'function'
        end, linter.args)

        local file = vim.api.nvim_buf_get_name(0)
        local module_root = vim.fs.root(file, 'go.mod')
        if module_root then
          table.insert(args, vim.fn.fnamemodify(file, ':p:h'))
        else
          table.insert(args, vim.fn.fnamemodify(file, ':p'))
        end

        return vim.tbl_extend('force', linter, {
          args = args,
          cwd = module_root or vim.fn.fnamemodify(file, ':p:h'),
        })
      end,
    },
    -- linters = {
    --   -- https://github.com/codespell-project/codespell?tab=readme-ov-file#ignoring-words
    --   codespell = {
    --     args = {
    --       '--ignore-words-list',
    --       'te', -- DHIS2 tracked entity
    --     },
    --   },
    -- },
  },
  config = function(_, opts)
    -- thank you LazyVim :)
    -- https://github.com/LazyVim/LazyVim/blob/67ff818a5bb7549f90b05e412b76fe448f605ffb/lua/lazyvim/plugins/linting.lua#L29
    local M = {}

    local lint = require('lint')
    for name, linter in pairs(opts.linters) do
      if type(linter) == 'table' and type(lint.linters[name]) == 'table' then
        lint.linters[name] = vim.tbl_deep_extend('force', lint.linters[name], linter)
      else
        lint.linters[name] = linter
      end
    end
    lint.linters_by_ft = opts.linters_by_ft

    function M.lint()
      -- Use nvim-lint's logic first:
      -- * checks if linters exist for the full filetype first
      -- * otherwise will split filetype by "." and add all those linters
      -- * this differs from conform.nvim which only uses the first filetype that has a formatter
      local names = vim.tbl_values(lint._resolve_linter_by_ft(vim.bo.filetype))

      -- Add fallback linters.
      if #names == 0 then
        vim.list_extend(names, lint.linters_by_ft['_'] or {})
      end

      -- Add global linters.
      vim.list_extend(names, lint.linters_by_ft['*'] or {})

      -- Filter out linters that don't exist or don't match the condition.
      local ctx = { filename = vim.api.nvim_buf_get_name(0) }
      ctx.dirname = vim.fn.fnamemodify(ctx.filename, ':h')
      names = vim.tbl_filter(function(name)
        local linter = lint.linters[name]
        if not linter then
          vim.notify('Linter not found: ' .. name, vim.log.levels.WARN)
        end
        return linter
          and not (type(linter) == 'table' and linter.condition and not linter.condition(ctx))
      end, names)

      -- Run linters.
      if #names > 0 then
        lint.try_lint(names)
      end
    end

    vim.api.nvim_create_autocmd(opts.events, {
      group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
      callback = Debounce(100, M.lint),
    })
  end,
}

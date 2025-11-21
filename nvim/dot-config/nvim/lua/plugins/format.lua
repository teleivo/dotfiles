return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      default_format_opts = {
        lsp_format = 'fallback',
      },
      formatters_by_ft = {
        dot = { 'dotfmt' },
        go = {
          lsp_format = 'first',  -- Go-specific: LSP first, then trim_whitespace
          'trim_whitespace'
        },
        java = { 'google-java-format' },
        json = { 'jq' },
        lua = { 'stylua' },
        python = {
          'ruff_fix',
          'ruff_format',
          'ruff_organize_imports',
        },
        sql = { 'sqlfmt' },
        -- "_" filetype is to run formatters on filetypes that don't have other formatters configured
        ['_'] = { 'trim_whitespace' },
      },
      formatters = {
        dotfmt = {
          -- build and run my development version so I can iterate more quickly
          command = 'go',
          args = { 'run', '.', 'fmt' },
          cwd = function()
            return vim.env.HOME .. '/code/dot/cmd/dotx'
          end,
        },
        sqlfmt = {
          prepend_args = function()
            return { '--no-progressbar', '--line-length', vim.o.textwidth }
          end,
        },
      },
      format_on_save = {
        timeout_ms = 10000, -- google-java-format is slow (at least in DHIS2 codebase)
      },
      -- :ConformInfo to get the log file location
      log_level = vim.log.levels.ERROR,
      notify_on_error = true,
      notify_no_formatters = true,
    },
    init = function()
      -- this is so that gq formats using formatters registered with conform (falls back to LSP)
      -- this will also be used by rest.vim to format response bodies
      vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}

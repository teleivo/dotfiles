return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    -- This will provide type hinting with LuaLS
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      -- prefer formatting done by an LSP and only use a formatters_by_ft if needed
      default_format_opts = {
        lsp_format = 'prefer',
      },
      formatters_by_ft = {
        java = { 'google-java-format' },
        json = { 'jq' },
        -- for some reason lsp_format='prefer' did not work with me wanting to use stylua for lua and
        -- turning off the LuaLS. Maybe conform does not check/know about the LSP config but only
        -- knows that the LuaLS is capable of formatting.
        lua = { 'stylua', lsp_format = 'fallback' },
      },
      format_on_save = {
        timeout_ms = 10000, -- google-java-format is slow (at least in DHIS2 codebase)
      },
      -- :ConformInfo to get the log file location
      log_level = vim.log.levels.ERROR,
      notify_on_error = true,
      notify_no_formatters = true,
    },
  },
}

return {
  'tpope/vim-dadbod',
  version = false,
  ft = { 'sql', 'mysql', 'plsql' },
  cmd = {
    'DB',
  },
  dependencies = {
    {
      'kristijanhusak/vim-dadbod-completion',
      version = false,
    },
  },
  init = function()
    -- define my mappings in ../../after/ftplugin/sql.lua
    vim.g.vim_dadbod_completion_lowercase_keywords = 1
    -- TODO can I come up with a function that reads from .env files? or fork the plugin to make it
    -- work like rest.nvim
    vim.g.dbs = {
      dev = 'postgres://dhis:dhis@localhost:5432/dhis',
      sync = 'postgres://dhis:dhis@localhost:5434/dhis',
    }
    -- default DB to run SQL against
    vim.g.db = vim.g.dbs.dev
  end,
}

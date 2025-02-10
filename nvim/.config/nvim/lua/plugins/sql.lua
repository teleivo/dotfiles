return {
  'kristijanhusak/vim-dadbod-ui',
  version = false, -- releases are too old
  ft = { 'sql', 'mysql', 'plsql' },
  cmd = {
    'DBUI',
    'DBUIAddConnection',
    'DBUIFindBuffer',
    'DBUIHideNotifications',
    'DBUILastQueryInfo',
    'DBUIRenameBuffer',
    'DBUIToggle',
  },
  dependencies = {
    { 'tpope/vim-dadbod', version = false, lazy = true },
    {
      'kristijanhusak/vim-dadbod-completion',
      version = false,
      lazy = true,
    },
  },
  init = function()
    -- define my mappings in ../../after/ftplugin/sql.lua
    vim.g.db_ui_disable_mappings_sql = 0
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_use_nvim_notify = 1
    vim.g.db_ui_execute_on_save = 0 -- use mapping to execute instead
    -- TODO can I set this dynamically? or how can I organize my queries in dirs so I can at least
    -- also use this for IM?
    vim.g.db_ui_save_location = vim.env.HOME .. '/code/dhis2/notes/sql'
    vim.g.vim_dadbod_completion_lowercase_keywords = 1
    -- TODO can I come up with a function that reads from .env files? or fork the plugin to make it
    -- work like rest.nvim
    vim.g.dbs = {
      { name = 'dev', url = 'postgres://dhis:dhis@localhost:5432/dhis' },
      { name = 'sync', url = 'postgres://dhis:dhis@localhost:5434/dhis' },
    }
  end,
}

return {
  'kristijanhusak/vim-dadbod-ui',
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
  },
  init = function()
    vim.g.db_ui_use_nvim_notify = 1
    vim.g.vim_dadbod_completion_lowercase_keywords = 1
    vim.g.dbs = {
      { name = 'dev', url = 'postgres://dhis:dhis@localhost:5432/dhis' },
    }
  end,
}

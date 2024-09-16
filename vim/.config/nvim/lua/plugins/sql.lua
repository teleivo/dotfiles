return {
  'kristijanhusak/vim-dadbod-ui',
  ft = { 'sql' },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  dependencies = {
    { 'tpope/vim-dadbod' },
    { 'kristijanhusak/vim-dadbod-completion' },
  },
  init = function()
    vim.g.db_ui_use_nvim_notify = 1
		vim.g.vim_dadbod_completion_lowercase_keywords = 1
    vim.g.dbs = {
      { name = 'dev', url = 'postgres://dhis:dhis@localhost:5432/dhis' },
    }
  end,
}

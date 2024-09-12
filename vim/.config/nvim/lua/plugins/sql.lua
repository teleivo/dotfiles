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
    -- Your DBUI configuration
    -- vim.g.db_ui_use_nerd_fonts = 1
  end,
}

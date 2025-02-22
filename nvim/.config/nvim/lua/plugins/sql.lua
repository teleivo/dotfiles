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
    -- mappings are defined in ../../after/ftplugin/sql.lua

    -- TODO is this completion even working? or ditch it right away for the lsp
    vim.g.vim_dadbod_completion_lowercase_keywords = 1
  end,
}

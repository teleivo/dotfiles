-- https://github.com/supabase-community/postgres-language-server
-- Database connection is configured dynamically via after/ftplugin/sql.lua
-- when user selects a database with <leader>re
return {
  cmd = { vim.env.HOME .. "/.local/bin/postgres-language-server", "lsp-proxy" },
  filetypes = { "sql" },
  root_markers = { ".git" },
  single_file_support = true,
  settings = {
    -- db connection configured dynamically when user selects a database
  },
}

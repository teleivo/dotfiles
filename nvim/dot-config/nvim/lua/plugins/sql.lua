-- SQL Development Environment
--
-- Two complementary tools provide a complete SQL editing experience:
--
-- vim-dadbod (this plugin) handles query execution:
--   * Execute queries and view results
--   * Run entire buffers, selections, or nearest statements
--   * Support for multiple database connections via .env files
--   * Integration with pgbench for benchmarking
--   * EXPLAIN ANALYZE with pev2 visualization
--
-- postgres-language-server (configured in lsp/postgres_lsp.lua) provides editing assistance:
--   * Schema-aware autocompletion (tables, columns, functions)
--   * Real-time syntax error highlighting
--   * Type checking via EXPLAIN
--   * Linting (Squawk rules for SQL best practices)
--
-- Both tools share the same database connection. When you select a database with <leader>re:
--   1. Connection URL is read from a .env file (looks for DB_URL* variables)
--   2. vim-dadbod uses vim.g.db for query execution
--   3. postgres-lsp receives the connection via workspace/didChangeConfiguration
--
-- Keymaps (defined in after/ftplugin/sql.lua):
--   <leader>re  Select .env file and database connection
--   <leader>rn  Run nearest SQL statement
--   <leader>rr  Run current buffer (normal) or selection (visual)
--   <leader>rb  Run pgbench benchmark
--   <leader>rx  Run EXPLAIN ANALYZE
--   <leader>rp  Generate EXPLAIN plan JSON for pev2
--   <leader>rw  Toggle pev2 watcher
return {
  'tpope/vim-dadbod',
  version = false,
  ft = { 'sql', 'mysql', 'plsql' },
  cmd = {
    'DB',
  },
  -- completion provided by postgres-lsp instead of vim-dadbod-completion
}

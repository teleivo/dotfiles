local ts = vim.treesitter

-- TODO move into my-treesitter.get_query(lang,name)
local custom_query_path = vim.env.DOTFILES .. '/vim/.config/nvim/queries/go/tests.scm'
local query_content = vim.fn.readfile(custom_query_path)
local custom_query = ts.query.parse('go', table.concat(query_content, '\n'))

local code = [[
package foo

func TestParser(t *testing.T) {
	t.Run("Header", func(t *testing.T) {
}
]]
local bufnr = 20
-- Example usage of your custom query
local parser = ts.get_parser(bufnr, 'go') -- Assuming you're working on a Lua file
local tree = parser:parse()[1]
Print(vim.treesitter.get_node_text(tree, bufnr))

-- for id, node, metadata in custom_query:iter_matches(tree:root(), bufnr) do
--   -- Process matches found by your custom query
--   print(ts.query.get_node_text(node, bufnr))
-- end

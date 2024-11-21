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
local bufnr = 14
-- Example usage of your custom query
local parser = ts.get_parser(bufnr, 'go') -- Assuming you're working on a Lua file
local tree = parser:parse()[1]
local root = tree:root()
-- Print(vim.treesitter.get_node_text(tree:root(), bufnr))

local tests = {}
for pattern, match, metadata in custom_query:iter_matches(root, bufnr) do
  -- Process matches found by your custom query
  -- Print(vim.treesitter.get_node_text(node, bufnr))
  for id, nodes in pairs(match) do
    local name = custom_query.captures[id]
    if name == 'name' then
      for _, node in ipairs(nodes) do
        -- `node` was captured by the `name` capture in the match
        -- local node_data = metadata[id] -- Node level metadata
        -- Print(vim.treesitter.get_node_text(node_data, bufnr))
        -- Print(node_data)
        local test_name = vim.treesitter.get_node_text(node, bufnr)
        table.insert(tests, test_name)
      end
    end
    -- for _, node in ipairs(nodes) do
    --   -- `node` was captured by the `name` capture in the match
    --   -- local node_data = metadata[id] -- Node level metadata
    --   Print(vim.treesitter.get_node_text(node, bufnr))
    -- end
  end
end
Print(tests)

local BUFNAME = 'go://tests'

function show()
  -- Check if the buffer is already open
  local buf = vim.fn.bufnr(BUFNAME)

  if buf ~= -1 then -- If buffer exists
    -- Check if it's currently visible in a window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == buf then
        -- If open, close the window
        vim.api.nvim_win_close(win, true)
        return
      end
    end
  else
    -- Create a new buffer if it doesn't exist
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, BUFNAME)
  end

  local height = math.ceil(vim.o.lines * 0.4) -- 80% of screen height
  local width = math.ceil(vim.o.columns * 0.4) -- 80% of screen width
  local win = vim.api.nvim_open_win(buf, true, {
    split = 'below',
    style = 'minimal',
    width = width,
    height = height,
  })

  vim.api.nvim_win_set_buf(win, buf)

  -- Get the directory of the current file
  -- local current_file_dir = vim.fn.expand('%:p:h')
  local current_file_dir = vim.fn.expand('#' .. bufnr .. ':p:h')
  Print(current_file_dir)
  -- Find the project root using .git as the marker
  local project_root = vim.fn.finddir('.git', current_file_dir .. ';')
  -- If .git is found, get its parent directory
  if project_root ~= '' then
    project_root = vim.fn.fnamemodify(project_root, ':h')
  else
    -- If no .git is found, use the current file's directory as fallback
    project_root = current_file_dir
  end
  vim.cmd('lcd ' .. vim.fn.fnameescape(project_root))

  -- Start a terminal in this buffer
  vim.cmd('terminal')

  -- Send the command to the terminal
  local term_job_id = vim.b.terminal_job_id
  vim.fn.chansend(term_job_id, 'go test ./... -run ' .. tests[1] .. ' \n')

  -- Automatically switch to insert mode for interaction
  vim.cmd('startinsert')
end

show()

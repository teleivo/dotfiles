local M = {}

local top_level_declaration_nodes = {
  java = {
    class_declaration = true,
    enum_declaration = true,
    interface_declaration = true,
    record_declaration = true,
  },
  go = {
    const_declaration = true,
    function_declaration = true,
    method_declaration = true,
    type_declaration = true,
    var_declaration = true,
  },
}

-- Select the first top level declaration node using treesitter. This should then position
-- the cursor on a class, enum, record, interface in Java or a const, type, var, function
-- and method declaration in Go https://go.dev/ref/spec#Declarations_and_scope.
M.top_level_declaration = function()
  if not top_level_declaration_nodes[vim.bo.filetype] then
    return
  end

  local ts_utils = require('nvim-treesitter.ts_utils')
  local _, tree = ts_utils.get_root_for_position(0, 0)
  if tree == nil then
    return
  end

  for node, _ in tree:root():iter_children() do
    if top_level_declaration_nodes[vim.bo.filetype][node:type()] ~= nil then
      local row = node:start() + 1
      vim.api.nvim_win_set_cursor(0, { row, 0 })
      return
    end
  end
end

return M

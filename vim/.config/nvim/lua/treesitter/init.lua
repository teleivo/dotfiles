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

M.NodeVisual = function()
  local _, _, tree = require('nvim-treesitter.ts_utils').get_root_for_position(0, 0)
  local range = M.Get_visual_selection_range()
  return tree:node_for_range(range)
end

M.Node = function(range)
  local _, _, tree = require('nvim-treesitter.ts_utils').get_root_for_position(0, 0)
  return tree:node_for_range(range)
end

M.Get_visual_selection_text = function()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, '\n')
end

M.Get_visual_selection_range = function()
  local selection_start = vim.fn.getpos("'<")
  local selection_end = vim.fn.getpos("'>")
  return { selection_start[2] - 1, selection_start[3] - 1, selection_end[2] - 1, selection_end[3] }
end

return M

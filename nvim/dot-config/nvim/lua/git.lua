local M = {}

M.is_in_git_repo = function()
  vim.fn.system('git rev-parse --is-inside-work-tree')
  return vim.v.shell_error == 0
end

-- Returns the file's git repository root directory path if file is in a git repo.
---@param file string: file for which the git repo path should be returned
M.get_git_root = function(file)
  local file_dir = vim.fn.expand(file .. ':h')
  local dot_git_path = vim.fn.finddir('.git', file_dir .. ';')
  return vim.fn.fnamemodify(dot_git_path, ':p:h:h') or ''
end

-- Returns the project name if file is in a git repo. The project name is the basename of the
-- parent directory of the .git directory. For example for file ~/dotfiles/README.md it will return
-- 'dotfiles'. Returns the tail of the file name if the file is not in a git repo.
---@param file string: file for which the git repo name
M.get_git_project_name = function(file)
  local file_name = vim.fn.expand(file .. ':t')
  local project_name = vim.fs.basename(M.get_git_root(file))
  return project_name or file_name
end

return M

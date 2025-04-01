local M = {}

function M.is_in_git_repo()
  local result = vim.system({ 'git', 'rev-parse', '--is-inside-work-tree' }):wait()
  return result.code == 0
end

-- Returns the file's git repository root directory path if file is in a git repo.
---@param file string: file for which the git repo path should be returned
function M.get_git_root(file)
  local file_dir = vim.fn.expand(file .. ':h')
  local dot_git_path = vim.fn.finddir('.git', file_dir .. ';')
  return vim.fn.fnamemodify(dot_git_path, ':p:h:h') or ''
end

-- Returns the directory name of the (parent) directory containing a '.git' directory. If a file is
-- given the search for '.git' starts at this files directory. If no file is given the current
-- buffers file is used as the starting directory.
--
-- For example for file ~/dotfiles/README.md it will return 'dotfiles'. Returns the tail of the file
-- name if the file is not in a git repo.
---@param file? string: file for which the git repo name
function M.get_git_project_name(file)
  if not file then
    return vim.fs.basename(vim.fs.root(0, '.git') or vim.fn.expand('%:t'))
  end

  local project_name = vim.fs.basename(M.get_git_root(file))
  return project_name or vim.fn.expand(file .. ':t')
end

return M

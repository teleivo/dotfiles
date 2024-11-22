local git = require('git')

local M = {}

local function get_git_root()
  local dot_git_path = vim.fn.finddir('.git', '.;')
  return vim.fn.fnamemodify(dot_git_path, ':h')
end

local function get_opts()
  local opts = {}
  if git.is_in_git_repo() then
    opts = {
      cwd = get_git_root(),
      hidden = true,
    }
  end
  return opts
end

-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#live-grep-from-project-git-root-with-fallback
M.project_live_grep = function()
  require('telescope.builtin').live_grep(get_opts())
end

-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#falling-back-to-find_files-if-git_files-cant-find-a-git-directory
M.project_find_files = function()
  require('telescope.builtin').find_files(get_opts())
end

M.dotfiles_find = function()
  require('telescope.builtin').find_files({
    prompt_title = '<~ dotfiles (partial) ~>',
    cwd = os.getenv('HOME') .. '/code/dotfiles',
    hidden = true,
  })
end

return M

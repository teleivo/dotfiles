local M = {}

-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#falling-back-to-find_files-if-git_files-cant-find-a-git-directory
M.project_files = function()
  local opts = {} -- define here if you want to define something
  local ok = pcall(require('telescope.builtin').git_files, opts)
  if not ok then
    require('telescope.builtin').find_files(opts)
  end
end

M.dotfiles = function()
  require('telescope.builtin').find_files({
    prompt_title = '<~ dotfiles ~>',
    cwd = os.getenv('HOME') .. '/code/dotfiles',
    hidden = true,
  })
end

return M

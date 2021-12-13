local M = {}

-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#falling-back-to-find_files-if-git_files-cant-find-a-git-directory
M.project_files = function()
  local opts = {} -- define here if you want to define something
  local ok = pcall(require('telescope.builtin').git_files, opts)
  if not ok then
    require('telescope.builtin').find_files(opts)
  end
end

-- I need to search through hidden directories due to the stow setup. I make
-- the search_dirs explicit, since there is no way for me to exclude the '.git' directory.
-- Ideally, I could provide a list of exclusions. Maybe one day :)
M.dotfiles = function()
  require('telescope.builtin').find_files({
    prompt_title = '<~ dotfiles (partial) ~>',
    cwd = os.getenv('HOME') .. '/code/dotfiles',
    search_dirs = { 'alacritty', 'alias', 'bin', 'fd', 'git', 'playbooks', 'shell', 'tmux', 'vim' },
    hidden = true,
  })
end

return M

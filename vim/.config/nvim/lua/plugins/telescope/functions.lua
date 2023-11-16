local M = {}

-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#falling-back-to-find_files-if-git_files-cant-find-a-git-directory
M.project_files = function()
  local function is_git_repo()
    vim.fn.system('git rev-parse --is-inside-work-tree')
    return vim.v.shell_error == 0
  end
  local function get_git_root()
    local dot_git_path = vim.fn.finddir('.git', '.;')
    return vim.fn.fnamemodify(dot_git_path, ':h')
  end
  local opts = {}
  if is_git_repo() then
    opts = {
      cwd = get_git_root(),
      hidden = true,
    }
  end
  require('telescope.builtin').find_files(opts)
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

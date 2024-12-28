local git = require('git')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local conf = require('telescope.config').values

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
function M.project_live_grep()
  M.live_multigrep(get_opts())
end

-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#falling-back-to-find_files-if-git_files-cant-find-a-git-directory
function M.project_find_files()
  require('telescope.builtin').find_files(get_opts())
end

function M.dotfiles_find()
  require('telescope.builtin').find_files({
    prompt_title = '<~ dotfiles (partial) ~>',
    cwd = os.getenv('HOME') .. '/code/dotfiles',
    hidden = true,
  })
end

-- Thank you tj!!!
-- https://github.com/tjdevries/advent-of-nvim/blob/13d4ec68a2a81f27264f3cc73dd7cd8c047aab87/nvim/lua/config/telescope/multigrep.lua#L8
function M.live_multigrep(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()

  local finder = finders.new_async_job({
    command_generator = function(prompt)
      if not prompt or prompt == '' then
        return nil
      end

      local pieces = vim.split(prompt, '  ')
      local args = { 'rg' }
      if pieces[1] then
        table.insert(args, '-e')
        table.insert(args, pieces[1])
      end

      if pieces[2] then
        table.insert(args, '-g')
        table.insert(args, pieces[2])
      end

      -- NOTE: keep in sync with options in ./init.lua! not sure if I could access these defaults
      local vimgrep_arguments = {
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case',
        '--hidden',
      }

      ---@diagnostic disable-next-line: deprecated
      return vim.tbl_flatten({
        args,
        vimgrep_arguments,
      })
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  })

  pickers
    .new(opts, {
      debounce = 100,
      finder = finder,
      previewer = conf.grep_previewer(opts),
      sorter = require('telescope.sorters').empty(),
    })
    :find()
end

return M

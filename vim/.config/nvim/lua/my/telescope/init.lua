-- https://github.com/nvim-telescope/telescope.nvim
-- https://github.com/nvim-telescope/telescope-fzf-native.nvim

-- TODO why do I have to type i in picker Buffer for example?
require('telescope').setup({
  defaults = {
    path_display = function(_, path)
      local tail = require('telescope.utils').path_tail(path)
      return string.format('%s (%s)', tail, path)
    end,
    winblend = 0,
    layout_strategy = 'horizontal',
    layout_config = {
      width = 0.95,
      height = 0.85,
      prompt_position = 'top',
      horizontal = {
        preview_width = function(_, cols, _)
          if cols > 200 then
            return math.floor(cols * 0.4)
          else
            return math.floor(cols * 0.6)
          end
        end,
      },
      vertical = {
        width = 0.9,
        height = 0.95,
        preview_height = 0.5,
      },
      flex = {
        horizontal = {
          preview_width = 0.9,
        },
      },
    },
    selection_strategy = 'reset',
    sorting_strategy = 'ascending',
    scroll_strategy = 'cycle',
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
    },
  },
})
-- To get fzf loaded and working with telescope
require('telescope').load_extension('dap')
require('telescope').load_extension('fzf')
require('telescope').load_extension('repo')
require('telescope').load_extension('test')

-- find things using telescope
local opts = { silent = true }
vim.keymap.set('n', '<C-p>', function()
  return require('telescope.builtin').builtin({ include_extensions = true })
end, opts)
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', opts)
vim.keymap.set('n', '<leader>fe', function()
  return require('telescope.builtin').file_browser({ hidden = true })
end, opts)
vim.keymap.set('n', '<leader>ff', function()
  return require('my.telescope.functions').project_files()
end, opts)
vim.keymap.set('n', '<leader>fd', function()
  return require('my.telescope.functions').dotfiles()
end, opts)
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>', opts)
vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>', opts)
vim.keymap.set('n', '<leader>fo', ':Telescope old_files<CR>', opts)
vim.keymap.set('n', '<leader>fr', ':Telescope resume<CR>', opts)

-- https://github.com/nvim-telescope/telescope.nvim
-- https://github.com/nvim-telescope/telescope-fzf-native.nvim

-- TODO why do I have to type i in picker Buffer for example?
require('telescope').setup({
  defaults = {
    path_display = { 'truncate' },
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
require('telescope').load_extension('fzf')
require('telescope').load_extension('repo')
require('telescope').load_extension('test')

-- find things using telescope
vim.api.nvim_set_keymap(
  'n',
  '<C-p>',
  '<CMD>lua require("telescope.builtin").builtin({ include_extensions = true })<CR>',
  { noremap = true }
)
vim.api.nvim_set_keymap(
  'n',
  '<leader>ff',
  "<CMD>lua require'my.telescope.functions'.project_files()<CR>",
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap('n', '<leader>fg', ':Telescope live_grep<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fb', ':Telescope buffers<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fh', ':Telescope help_tags<CR>', { noremap = true })

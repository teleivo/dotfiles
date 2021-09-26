-- https://github.com/nvim-telescope/telescope.nvim
-- https://github.com/nvim-telescope/telescope-fzf-native.nvim
require('telescope').setup {
  defaults = {
    layout_strategy = 'vertical',
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
    }
  }
}
-- To get fzf loaded and working with telescope
require('telescope').load_extension('fzf')

-- find things using telescope
vim.api.nvim_set_keymap('n', '<C-p>', '<CMD>lua require("telescope.builtin").builtin({ include_extensions = true })<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>ff', '<CMD>lua require\'my.telescope.functions\'.project_files()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fg', ':Telescope live_grep<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>fb', ':Telescope buffers<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>fh', ':Telescope help_tags<CR>', { noremap = true})

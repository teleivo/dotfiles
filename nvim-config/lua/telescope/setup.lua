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

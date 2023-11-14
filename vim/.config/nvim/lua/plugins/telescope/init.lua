-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#falling-back-to-find_files-if-git_files-cant-find-a-git-directory
local project_files = function()
  local opts = {}
  local ok = pcall(require('telescope.builtin').git_files, opts)
  if not ok then
    require('telescope.builtin').find_files(opts)
  end
end

-- I need to search through hidden directories due to the stow setup. I make
-- the search_dirs explicit, since there is no way for me to exclude the '.git' directory.
-- Ideally, I could provide a list of exclusions. Maybe one day :)
local dotfiles = function()
  require('telescope.builtin').find_files({
    prompt_title = '<~ dotfiles (partial) ~>',
    cwd = os.getenv('HOME') .. '/code/dotfiles',
    search_dirs = { 'alacritty', 'alias', 'bin', 'fd', 'git', 'playbooks', 'shell', 'tmux', 'vim' },
    hidden = true,
  })
end

-- open file finder only if neovim is started without arguments
local group = vim.api.nvim_create_augroup('VimEnterTelescope', { clear = true })
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.tbl_count(vim.v.argv) == 1 then
      project_files()
    end
  end,
  once = true,
  group = group,
  pattern = '*',
})

-- TODO why do I have to type i in picker Buffer for example?
return {
  {
    'nvim-telescope/telescope.nvim',
    lazy = false,
    event = 'VimEnter',
    cmd = 'Telescope',
    version = false, -- telescope did only one release, so use HEAD for now
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-dap.nvim',
      'cljoly/telescope-repo.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        enabled = vim.fn.executable('make') == 1,
      },
    },
    config = function(_, opts)
      require('telescope').setup(opts)
      -- TODO requires mfusseneger/nvim-dap require('telescope').load_extension('dap')
      -- To get fzf loaded and working with telescope
      require('telescope').load_extension('fzf')
      require('telescope').load_extension('repo')
    end,
    init = function()
      if vim.tbl_count(vim.v.argv) == 1 then
        project_files()
      end
    end,
    opts = {
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
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
        },
      },
    },
    keys = {
      {
        '<C-p>',
        function()
          require('telescope.builtin').builtin({ include_extensions = true })
        end,
      },
      {
        '<leader>fb',
        function()
          require('telescope.builtin').buffers()
        end,
      },
      {
        '<leader>fe',
        function()
          require('telescope.builtin').diagnostics()
        end,
      },
      {
        '<leader>ff',
        function()
          require('my.telescope.functions').project_files()
        end,
      },
      --{'<leader>fd', function() require('my.telescope.functions').dotfiles() end },
      {
        '<leader>fg',
        function()
          require('telescope.builtin').live_grep()
        end,
      },
      {
        '<leader>fh',
        function()
          require('telescope.builtin').help_tags()
        end,
      },
      {
        '<leader>fo',
        function()
          require('telescope.builtin').oldfiles()
        end,
      },
      {
        '<leader>fr',
        function()
          require('telescope.builtin').resume()
        end,
      },
    },
  },
}

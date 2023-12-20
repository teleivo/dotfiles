-- Returns the project name if file is in a git repo. The project name is the basename of the
-- parent directory of the .git directory. For example for file ~/dotfiles/TODO.md it will return
-- 'dotfiles'. Returns the tail of the file name if the file is not in a git repo.
local function get_git_project_name(file)
  local file_dir = vim.fn.expand(file .. ':h')
  local file_name = vim.fn.expand(file .. ':t')
  local dot_git_path = vim.fn.finddir('.git', file_dir .. ';')
  local project_root = vim.fn.fnamemodify(dot_git_path, ':p:h:h')
  local project_name = vim.fs.basename(project_root)
  return project_name or file_name
end

-- lualine config from creator of wadackel/vim-dogrun colorscheme
-- https://github.com/wadackel/dotfiles/blob/ffe3d4a41009578a74af4384940dc5c84b530144/init.vim#L1350
local colors = {
  purple = '#929be5',
  teal = '#73c1a9',
  pink = '#b871b8',
  red = '#dc6f7a',

  bg = '#282a3a',
  fg = '#4b4e6d',

  inactive = {
    bg = '#282a3a',
    fg = '#4b4e6d',
  },
}

-- based on example theme
-- https://github.com/nvim-lualine/lualine.nvim/blob/master/examples/bubbles.lua
local bubbles_theme = {
  normal = {
    -- TODO I use the same colors in section a as in b as I cannot make use of rounded edges with my font
    -- also at least for now globalstatus=true does not seem to work, so the colors are just too
    -- much as the statusline is duplicated in splits. Also the tabline shows colors till the end
    -- instead of just for the chip.
    -- fix statusline: color should not expand til the end
    -- fix rounded edges
    -- a = { fg = colors.bg, bg = colors.purple },
    a = { fg = colors.purple, bg = colors.bg },
    b = { fg = colors.purple, bg = colors.bg },
    c = { fg = colors.fg, bg = colors.bg },
    x = { fg = colors.inactive.fg, bg = colors.inactive.bg },
    y = { fg = colors.inactive.fg, bg = colors.inactive.bg },
  },
  insert = {
    -- a = { fg = colors.bg, bg = colors.teal },
    a = { fg = colors.teal, bg = colors.bg },
    b = { fg = colors.teal, bg = colors.bg },
    x = { fg = colors.inactive.fg, bg = colors.inactive.bg },
    y = { fg = colors.inactive.fg, bg = colors.inactive.bg },
  },
  visual = {
    -- a = { fg = colors.bg, bg = colors.pink },
    a = { fg = colors.pink, bg = colors.bg },
    b = { fg = colors.pink, bg = colors.bg },
    x = { fg = colors.inactive.fg, bg = colors.inactive.bg },
    y = { fg = colors.inactive.fg, bg = colors.inactive.bg },
  },
  replace = {
    -- a = { fg = colors.bg, bg = colors.red },
    a = { fg = colors.red, bg = colors.bg },
    b = { fg = colors.red, bg = colors.bg },
    x = { fg = colors.inactive.fg, bg = colors.inactive.bg },
    y = { fg = colors.inactive.fg, bg = colors.inactive.bg },
  },
  command = {
    -- a = { fg = colors.bg, bg = colors.teal },
    a = { fg = colors.teal, bg = colors.bg },
    b = { fg = colors.teal, bg = colors.bg },
    x = { fg = colors.inactive.fg, bg = colors.inactive.bg },
    y = { fg = colors.inactive.fg, bg = colors.inactive.bg },
  },
  terminal = {
    -- a = { fg = colors.bg, bg = colors.teal },
    a = { fg = colors.teal, bg = colors.bg },
    b = { fg = colors.teal, bg = colors.bg },
    x = { fg = colors.inactive.fg, bg = colors.inactive.bg },
    y = { fg = colors.inactive.fg, bg = colors.inactive.bg },
  },
  inactive = {
    a = { fg = colors.inactive.fg, bg = colors.inactive.bg },
    b = { fg = colors.inactive.fg, bg = colors.inactive.bg },
    c = { fg = colors.inactive.fg, bg = colors.inactive.bg },
  },
}

return {
  'nvim-lualine/lualine.nvim',
  lazy = false,
  opts = {
    options = {
      theme = bubbles_theme,
      component_separators = '',
      section_separators = '',
      always_divide_middle = false,
      icons_enabled = false,
    },
    sections = {
      lualine_a = {
        {
          'mode',
        },
      },
      lualine_b = {
        {
          'branch',
          padding = { left = 1 },
        },
        {
          'filename',
          padding = 1,
          path = 4,
          show_modified_status = true,
          symbols = {
            modified = '∙',
            readonly = '',
            unnamed = '[No Name]',
            newfile = '∙',
          },
        },
        {
          'diagnostics',
          sources = {
            'nvim_diagnostic',
          },
          sections = {
            'error',
            'warn',
            'info',
          },
          symbols = {
            error = '🤖',
            warn = ' ',
            info = '💡',
          },
        },
      },
      lualine_c = {},
      lualine_x = {},
      lualine_y = {
        {
          'filetype',
          padding = 0,
          colored = false,
        },
        'encoding',
      },
      lualine_z = {
        {
          'location',
          padding = 0,
        },
      },
    },
    inactive_sections = {
      lualine_a = {
        'filename',
      },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = { 'location' },
    },
    tabline = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        {
          'tabs',
          mode = 2, -- tab nr + name
          tabs_color = {
            active = 'lualine_a_normal',
            inactive = 'lualine_a_inactive',
          },
          show_modified_status = false, -- I want the modified status to show after the name. This would show it before.
          tab_max_length = 0, -- don't shorten the path so fmt has the full path
          path = 2, -- pass full path to fmt
          fmt = function(name, context)
            local buflist = vim.fn.tabpagebuflist(context.tabnr)
            local winnr = vim.fn.tabpagewinnr(context.tabnr)
            local bufnr = buflist[winnr]
            local mod = vim.fn.getbufvar(bufnr, '&mod')
            local project_name = get_git_project_name(name)

            return project_name .. (mod == 1 and ' ∙' or '')
          end,
        },
      },
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    extensions = {
      'fugitive',
    },
  },
  config = function(_, opts)
    require('lualine').setup(opts)
    -- only show tabline if there are at least 2 tabs
    vim.o.showtabline = 1
    -- use global status line (use of lualine option globalstatus did not work)
    vim.o.laststatus = 3
  end,
}

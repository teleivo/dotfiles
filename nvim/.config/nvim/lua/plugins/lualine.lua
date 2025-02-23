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
    a = { fg = colors.bg, bg = colors.purple },
    b = { fg = colors.purple, bg = colors.bg },
    c = { fg = colors.fg, bg = colors.bg },
    x = { fg = colors.inactive.fg, bg = colors.inactive.bg },
    y = { fg = colors.inactive.fg, bg = colors.inactive.bg },
  },
  insert = {
    a = { fg = colors.bg, bg = colors.teal },
    b = { fg = colors.teal, bg = colors.bg },
    x = { fg = colors.inactive.fg, bg = colors.inactive.bg },
    y = { fg = colors.inactive.fg, bg = colors.inactive.bg },
  },
  visual = {
    a = { fg = colors.bg, bg = colors.pink },
    b = { fg = colors.pink, bg = colors.bg },
    x = { fg = colors.inactive.fg, bg = colors.inactive.bg },
    y = { fg = colors.inactive.fg, bg = colors.inactive.bg },
  },
  replace = {
    a = { fg = colors.bg, bg = colors.red },
    b = { fg = colors.red, bg = colors.bg },
    x = { fg = colors.inactive.fg, bg = colors.inactive.bg },
    y = { fg = colors.inactive.fg, bg = colors.inactive.bg },
  },
  command = {
    a = { fg = colors.bg, bg = colors.teal },
    b = { fg = colors.teal, bg = colors.bg },
    x = { fg = colors.inactive.fg, bg = colors.inactive.bg },
    y = { fg = colors.inactive.fg, bg = colors.inactive.bg },
  },
  terminal = {
    a = { fg = colors.bg, bg = colors.teal },
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
  dependencies = {
    {
      'nvim-tree/nvim-web-devicons',
    },
  },
  opts = {
    options = {
      theme = bubbles_theme,
      component_separators = ' ',
      section_separators = { left = '', right = '' },
      always_divide_middle = false,
    },
    sections = {
      lualine_a = {
        {
          'mode',
          separator = { left = '', right = '' },
        },
      },
      lualine_b = {
        {
          'branch',
          padding = { left = 1 },
          on_click = function()
            vim.cmd(':GBrowse')
          end,
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
      lualine_c = {
        {
          'g:lualine_db',
          color = 'WarningMsg',
          cond = function()
            return vim.bo.filetype == 'sql'
          end,
          on_click = function()
            vim.cmd('edit ' .. vim.g.lualine_db_file)
          end,
        },
        {
          function()
            -- note that I am relying on a "private" var
            local env_file = vim.fn.fnamemodify(vim.b._rest_nvim_env_file, ':p')
            return vim.fn.fnamemodify(env_file, ':h:t') .. '/' .. vim.fn.fnamemodify(env_file, ':t')
          end,
          cond = function()
            return vim.bo.filetype == 'http'
          end,
          on_click = function()
            vim.cmd('edit ' .. vim.b._rest_nvim_env_file)
          end,
        },
      },
      lualine_x = {},
      lualine_y = {
        {
          'filetype',
          icon_only = true,
        },
        {
          'encoding',
          padding = 0,
        },
        {
          'progress',
        },
      },
      lualine_z = {
        {
          'location',
          padding = 0,
          separator = { left = '', right = '' },
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
          separator = { right = '' },
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
            local project_name = require('git').get_git_project_name(name)

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

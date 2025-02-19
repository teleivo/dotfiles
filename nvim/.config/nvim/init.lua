local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- need to require them before loading lazy! I can't move them into ./plugin/ as these are loaded
-- after this init.lua and thus lazy.
require('mappings')
require('globals')

require('lazy').setup('plugins', {
  defaults = {
    version = '*',
  },
  dev = {
    path = '~/code/neovim/plugins',
  },
  ui = {
    icons = {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤',
    },
  },
  change_detection = {
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        'tutor',
      },
    },
  },
})

vim.o.mouse = 'a'
-- remove the "How-to disable mouse" item
vim.cmd([[
  aunmenu PopUp.How-to\ disable\ mouse
  aunmenu PopUp.-2-
]])
-- looks
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.signcolumn = 'auto' -- only show signcolumn on errors
vim.o.termguicolors = true

vim.o.textwidth = 100 -- longer lines will be broken up
vim.o.wrap = false
vim.o.breakindent = true
vim.o.cursorline = true
vim.opt.listchars = { tab = '>-', trail = '*', eol = '¬' } -- define how whitespace is shown
vim.o.showmode = false
local group = vim.api.nvim_create_augroup('my_vimrc', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = group,
  desc = 'Highlight yanked text',
})

vim.o.errorbells = false

vim.o.swapfile = false
vim.o.autowrite = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.hidden = true
-- used to trigger the CursorHold autocommand event sooner than default (4000ms)
-- relied on by for example the treesitter-playground query_linter
vim.o.updatetime = 250
-- needs to be > than my voyager auto-shift timeout + typing speed as I cannot trigger sequences
-- like ]d to jump to diagnostics while the non-shifted sequence [d will work just fine
vim.o.timeoutlen = 400

vim.opt.completeopt = { 'menu', 'menuone', 'noinsert' } -- to have a better completion experience
vim.o.wildmode = 'list:longest,full' -- shows list of commands when doing completion in cmd line via tab
-- search options
vim.o.hlsearch = false -- stop highlighting when I am done searching
vim.o.incsearch = true -- highlight search results while typing
-- case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true -- search ignoring case...
vim.o.smartcase = true -- but not when search pattern has upper case character

vim.g.netrw_banner = false
vim.g.netrw_winsize = 30
vim.g.netrw_preview = true
vim.g.netrw_bufsettings =
  'nomodifiable nomodified number relativenumber nobuflisted nowrap readonly'

-- highlight codefences returned from denols
vim.g.markdown_fenced_languages = {
  'ts=typescript',
}

vim.o.undofile = true
-- sync clipboard between OS and Neovim
vim.o.clipboard = 'unnamedplus'
-- important for vim-go
-- used for auto_type_info adjust if needed, default is 800ms
vim.opt.shortmess:append({ c = false }) -- don't pass messages to |ins-completion-menu|

vim.diagnostic.config({
  float = {
    source = true,
    border = 'rounded',
  },
})

vim.api.nvim_create_autocmd('StdinReadPost', {
  command = 'set nomodified',
  group = group,
  desc = "Don't set modified when reading from stdin",
})
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost' }, {
  command = 'silent! wall',
  group = group,
  desc = 'Write modified buffers',
})
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '.tmux.conf',
  command = '!tmux source-file %',
  group = group,
  desc = 'Reload tmux config',
})
-- automatically rebalance windows on vim resize (useful when creating tmux
-- panes, so that vim splits are not looking like they are hidden)
vim.api.nvim_create_autocmd('VimResized', {
  command = ':wincmd =',
  group = group,
  desc = 'Rebalance vim splits',
})

vim.cmd([[
  filetype plugin indent on
]])

-- open file finder only if neovim is started without arguments
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local file_args = vim.tbl_filter(function(arg)
      return not vim.startswith(arg, 'nvim') and not vim.startswith(arg, '-')
    end, vim.v.argv)

    if vim.tbl_isempty(file_args) then
      require('plugins.telescope.functions').project_find_files()
    end
  end,
  once = true,
  group = group,
  desc = 'Open telescope on entering vim without a filepath',
})

local executed_buffers = {}

-- go to the top node of interest, especially useful for projects with huge license headers at the top
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function(args)
    local buf = args.buf
    if not executed_buffers[buf] then
      executed_buffers[buf] = true
      require('my-treesitter').top_level_declaration()
    end
  end,
})

vim.api.nvim_create_user_command(
  'BufOnly',
  '%bdelete|edit #|bdelete #|normal `"',
  { bang = true, desc = 'Delete all buffers but current one' }
)

-- Define a custom filetype 'timesheet' for DHIS2 timeskeeping and associate it with markdown
-- Use it mainly to add custom snippets
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = vim.env.HOME .. '/code/dhis2/reporting/timekeeping/*.md',
  callback = function()
    vim.bo.filetype = 'timesheet'
    vim.cmd('setlocal syntax=markdown')
    -- TODO fix this as that is not correct, do I even need it?
    -- vim.b.current_syntax = 'markdown'
    -- needed so that treesitter uses markdown to parse timesheets
    vim.treesitter.language.register('markdown', 'timesheet')
  end,
})

vim.diagnostic.config({ virtual_text = true })

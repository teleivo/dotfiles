-- This is my plugin for development in Rust.
-- Thank you to https://github.com/nvim-neorocks/nvim-best-practices ♥

---@class RustSubCommands
---@field impl fun(args:string[], opts: table) the command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) command completions callback, taking the lead of the subcommand's arguments

--- Returns the items matching the lead of the first argument. Does not complete any further
--- arguments.
--- @param items string[]
--- @param subcmd_arg_lead string
--- @return string[]
local function complete_first_arg(items, subcmd_arg_lead)
  if subcmd_arg_lead:find('%s') then
    return {}
  end

  return vim
    .iter(items)
    :filter(function(item)
      return item:find(subcmd_arg_lead, 1, true) ~= nil
    end)
    :totable()
end

--- Finds files or greps in given directory.
--- @param action string 'file' or 'grep'
--- @param dir string?
--- @param title string
local function search(action, dir, title)
  if not dir then
    return
  end

  local opts = { cwd = dir }
  if action == 'file' then
    opts.prompt_title = 'Search for ' .. title .. ' file'
    require('telescope.builtin').find_files(opts)
  elseif action == 'grep' then
    opts.prompt_title = 'Grep ' .. title .. ' code'
    require('plugins.telescope.functions').live_multigrep(opts)
  else
    vim.notify(
      "Rust: expected 'file' or 'grep', got '" .. (action or '') .. "'",
      vim.log.levels.ERROR
    )
  end
end

---@type table<string, RustSubCommands>
local subcommands = {
  lib = {
    impl = function(args)
      search(args[1], require('my-rust').stdlib_src_dir(), 'Rust standard library')
    end,
    complete = function(subcmd_arg_lead)
      return complete_first_arg({ 'file', 'grep' }, subcmd_arg_lead)
    end,
  },
  dep = {
    impl = function(args)
      if not args[2] then
        vim.notify('Rust: expected a package name', vim.log.levels.ERROR)
        return
      end
      search(args[1], require('my-rust').package_dir(args[2]), args[2])
    end,
    complete = function(subcmd_arg_lead)
      local action, package_lead = subcmd_arg_lead:match('^(%S+)%s+(%S*)$')
      if not action then
        return complete_first_arg({ 'file', 'grep' }, subcmd_arg_lead)
      end
      return complete_first_arg(require('my-rust').packages(), package_lead)
    end,
  },
  doc = {
    impl = function(args)
      if not args[1] then
        require('my-rust').doc_under_cursor()
        return
      end
      require('my-rust').doc(args[1], table.concat(args, ' ', 2))
    end,
    complete = function(subcmd_arg_lead)
      return complete_first_arg(require('my-rust').doc_targets(), subcmd_arg_lead)
    end,
  },
  expand = {
    impl = function()
      require('my-rust').expand_macro()
    end,
  },
  parent = {
    impl = function()
      require('my-rust').parent_module()
    end,
  },
  cargo = {
    impl = function()
      require('my-rust').open_cargo_toml()
    end,
  },
}

---@param opts table :h lua-guide-commands-create
local function cmd(opts)
  local fargs = opts.fargs
  local subcommand_key = fargs[1]

  -- Get the subcommand's arguments, if any
  local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
  local subcommand = subcommands[subcommand_key]
  if not subcommand then
    vim.notify('Rust: unknown command: ' .. subcommand_key, vim.log.levels.ERROR)
    return
  end

  subcommand.impl(args, opts)
end

vim.api.nvim_buf_create_user_command(0, 'Rust', cmd, {
  nargs = '+',
  desc = 'Command for development in Rust',
  complete = function(arg_lead, cmdline, _)
    -- get the subcommand
    local subcmd_key, subcmd_arg_lead = cmdline:match("^['<,'>]*Rust[!]*%s(%S+)%s(.*)$")
    if
      subcmd_key
      and subcmd_arg_lead
      and subcommands[subcmd_key]
      and subcommands[subcmd_key].complete
    then
      -- return subcommand completions
      return subcommands[subcmd_key].complete(subcmd_arg_lead)
    end

    -- check if cmdline is a subcommand
    if cmdline:match("^['<,'>]*Rust[!]*%s+%w*$") then
      -- filter matching subcommands
      local subcommand_keys = vim.tbl_keys(subcommands)
      return vim
        .iter(subcommand_keys)
        :filter(function(key)
          return key:find(arg_lead) ~= nil
        end)
        :totable()
    end
  end,
  bang = false,
})

vim.keymap.set('n', 'gK', function()
  require('my-rust').doc_under_cursor()
end, { buffer = true, desc = 'Open local docs of symbol under cursor' })

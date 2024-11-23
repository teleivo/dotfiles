-- This is my plugin for development in Go.
-- Thank you to https://github.com/nvim-neorocks/nvim-best-practices ♥

---@class GoSubCommands
---@field impl fun(args:string[], opts: table) the command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) command completions callback, taking the lead of the subcommand's arguments

---@type table<string, GoSubCommands>
local subcommands = {
    -- require('go.plugin_common').setup()
    --
    -- local go = require('my-go')
    --
    -- vim.api.nvim_create_user_command('GoAddImport', function(cmd)
    --   local import_path = cmd.fargs[1]
    --   go.add_import(import_path)
    -- end, {
    --   nargs = 1,
    -- })
  test = {
    impl = function(args)
      require('my-go').test(unpack(args))
    end,
    complete = function(subcmd_arg_lead)
      -- TODO if in a test file us the bufnr = 0 otherwise pasS in all open buffers?
      local go = require('my-go')
      local tests = go.find_tests()
      if not tests then
        return {}
      end

      return vim
        .iter(tests)
        :filter(function(install_arg)
          -- If the user has typed `:Go test TestX`,
          -- this will match 'TestX'
          return install_arg:find(subcmd_arg_lead) ~= nil
        end)
        :totable()
    end,
    -- ...
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
    vim.notify('Go: unknown command: ' .. subcommand_key, vim.log.levels.ERROR)
    return
  end

  subcommand.impl(args, opts)
end

vim.api.nvim_create_user_command('Go', cmd, {
  nargs = '+',
  desc = 'Command for development in Go',
  complete = function(arg_lead, cmdline, _)
    -- get the subcommand
    local subcmd_key, subcmd_arg_lead = cmdline:match("^['<,'>]*Go[!]*%s(%S+)%s(.*)$")
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
    if cmdline:match("^['<,'>]*Go[!]*%s+%w*$") then
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

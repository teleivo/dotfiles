-- This is my plugin for development in Go.
-- Thank you to https://github.com/nvim-neorocks/nvim-best-practices ♥
--
-- TODO is there a way to describe subcommands? so it also shows up in the cmp menu?

---@class GoSubCommands
---@field impl fun(args:string[], opts: table) the command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) command completions callback, taking the lead of the subcommand's arguments

---@type table<string, GoSubCommands>
local subcommands = {
  -- TODO bring the commands back
  -- local go = require('my-go')
  -- local go_telescope = require('my-go.plugins.telescope')
  -- vim.api.nvim_create_user_command('GoModAdd', function(cmd)
  --   if cmd.fargs == nil or #cmd.fargs == 0 then
  --     go_telescope.pick_dependency()
  --   end
  --
  --   local module_path = cmd.fargs[1]
  --   local module_version = cmd.fargs[2]
  --   go.add_dependency(module_path, module_version)
  -- end, {
  --   nargs = '*',
  -- })
  mod = {
    impl = function(args)
      if args[1] == 'tidy' then
        require('my-go').gomod_tidy()
      end
    end,
    complete = function()
      return { 'tidy', 'add' }
    end,
  },
  import = {
    impl = function(args)
      require('my-go').import(args[1])
    end,
    complete = function(subcmd_arg_lead)
      local packages = require('my-go').go_list()

      return vim
        .iter(packages)
        :map(function(package)
          return package.import_path
        end)
        :filter(function(import_path_arg)
          return import_path_arg:find(subcmd_arg_lead) ~= nil
        end)
        :totable()
    end,
  },
  test = {
    impl = function(args)
      require('my-go').go_test(unpack(args))
    end,
    complete = function(subcmd_arg_lead)
      -- TODO if in a test file us the bufnr = 0 otherwise pass in all open buffers?
      local go = require('my-go')
      local tests = go.find_tests()
      if not tests then
        return {}
      end

      return vim
        .iter(tests)
        :map(function(test)
          return test.name
        end)
        :filter(function(arg)
          -- If the user has typed `:Go test TestX`,
          -- this will match 'TestX'
          return arg:find(subcmd_arg_lead) ~= nil
        end)
        :totable()
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

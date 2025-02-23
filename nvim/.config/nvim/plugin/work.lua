-- This is my plugin for work on DHIS2.
-- Thank you to https://github.com/nvim-neorocks/nvim-best-practices ♥

local current_issue_link = vim.env.HOME .. '/code/dhis2/current_issue'

local M = {}

---@class WorkSubCommands
---@field impl fun(args:string[], opts: table) the command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) command completions callback, taking the lead of the subcommand's arguments

---@type table<string, WorkSubCommands>
local subcommands = {
  -- Select a new issue or existing issue.
  -- This entails
  -- - creating an issue dir
  -- - creating an issue markdown file
  -- - setting the current issue symlink
  -- - setting the issue register to the issue number
  issue = {
    impl = function(args)
      if not args[1] then
        return
      end

      -- extract trailing part of url like https://dhis2.atlassian.net/browse/DHIS2-12123
      local issue_nr = args[1]:match('[^/]+$')
      local issue_dir = vim.env.HOME .. '/code/dhis2/notes/issues/' .. issue_nr .. '/'
      local issue_jira = 'https://dhis2.atlassian.net/browse/' .. issue_nr
      local issue_markdown = issue_dir .. issue_nr .. '.md'

      vim.fn.mkdir(issue_dir, 'p')
      if vim.fn.filereadable(issue_markdown) == 0 then
        local file = io.open(issue_markdown, 'w')
        if file then
          local header = '# [' .. issue_nr .. '](' .. issue_jira .. ')'
          file:write(header)
          file:write('\n')
          file:close()
        end
      end

      os.remove(current_issue_link)
      if not vim.uv.fs_symlink(issue_dir, current_issue_link, { dir = true }) then
        vim.notify(
          'Work: failed to symlink the issue ' .. issue_nr .. ' dir to ' .. current_issue_link,
          vim.log.levels.ERROR
        )
      end

      vim.fn.setreg('w', issue_nr)
      -- using it for example in the lualine
      vim.g.work_issue = issue_nr
      vim.g.work_jira = issue_jira

      vim.cmd('edit ' .. issue_markdown)
    end,
    -- Show existing issue numbers as completion options
    complete = function(subcmd_arg_lead)
      local issue_dir = vim.env.HOME .. '/code/dhis2/notes/issues/'
      return vim
        .iter(vim.fs.dir(issue_dir, { depth = 1, follow = false }))
        :filter(function(k, v)
          return v == 'directory' and k:find(subcmd_arg_lead) ~= nil
        end)
        :map(function(k)
          return k
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
    vim.notify('Work: unknown command: ' .. subcommand_key, vim.log.levels.ERROR)
    return
  end

  subcommand.impl(args, opts)
end

vim.api.nvim_create_user_command('Work', cmd, {
  nargs = '+',
  desc = 'Command for development on DHIS2',
  complete = function(arg_lead, cmdline, _)
    -- get the subcommand
    local subcmd_key, subcmd_arg_lead = cmdline:match("^['<,'>]*Work[!]*%s(%S+)%s(.*)$")
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
    if cmdline:match("^['<,'>]*Work[!]*%s+%w*$") then
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

function M.current_issue()
  return vim.fs.basename(vim.uv.fs_realpath(current_issue_link) or '')
end

return M

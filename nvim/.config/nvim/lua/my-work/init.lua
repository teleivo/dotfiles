-- This is my plugin for work on DHIS2.
-- Thank you to https://github.com/nvim-neorocks/nvim-best-practices ♥

local notes_dir = vim.env.HOME .. '/code/dhis2/notes/'
local issues_dir = notes_dir .. 'issues/'
local current_issue_link = vim.env.HOME .. '/code/dhis2/current_issue'

local M = {}

---@return string jira issue number
function M.current_issue()
  return vim.fs.basename(vim.uv.fs_realpath(current_issue_link) or '')
end

---@param issue_nr string
---@return string jira issue url
local issue_jira = function(issue_nr)
  return 'https://dhis2.atlassian.net/browse/' .. issue_nr
end

---@param issue_nr string
---@return string issue directory
local issue_dir = function(issue_nr)
  return issues_dir .. issue_nr .. '/'
end

---@param issue_nr string
---@return string issue markdown file
local issue_markdown = function(issue_nr)
  return issue_dir(issue_nr) .. issue_nr .. '.md'
end

-- Set the current issue I am working on in the register and globals for things like lualine to pick
-- it up.
---@param issue_nr string jira issue number
local set_issue_details = function(issue_nr)
  -- set the "w" register - mnemonic work
  vim.fn.setreg('w', issue_nr)
  -- using it for example in the lualine
  vim.g.work_issue = issue_nr
  vim.g.work_jira = issue_jira(issue_nr)

  -- only do this inside of the notes_dir as I don't want to affect work on other DHIS2 repos
  if vim.fn.fnamemodify(vim.fn.getcwd(), ':p'):find(notes_dir, 1, true) then
    -- set the windows directory
    local dir = issue_dir(issue_nr)
    vim.cmd('cd ' .. dir)
    -- make sure the buffer is loaded. This helps me open it more quickly after I opened vim in my
    -- notes either with/without any file like 'vim' or 'vim TODO.md'.
    vim.cmd('badd ' .. issue_markdown(issue_nr))
    vim.api.nvim_buf_set_mark(vim.fn.bufnr(issue_markdown(issue_nr)), 'W', 1, 0, {})
  end
end

-- Set work issue on startup based on the current issue symlink directory
set_issue_details(M.current_issue())

---@class WorkSubCommands
---@field impl fun(args:string[], opts: table) the command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) command completions callback, taking the lead of the subcommand's arguments

---@type table<string, WorkSubCommands>
local subcommands = {
  -- View the PR of the current branch or create a PR against the remote tracking branch.
  pr = {
    impl = function(args)
      if args[1] == 'view' then
        local branch_result = vim
          .system({ 'git', 'rev-parse', '--abbrev-ref', 'HEAD' }, {
            text = true,
            stderr = false,
          })
          :wait()

        if branch_result.code ~= 0 then
          vim.notify(
            'Work: failed to get branch name with error: ' .. (branch_result.stderr or ''),
            vim.log.levels.ERROR
          )
        end

        local branch = vim.trim(branch_result.stdout)
        local cmd = { 'gh', 'pr', 'view', '--web', branch }

        local result = vim.system(cmd, { text = true }):wait()
        if result.code == 0 then
          vim.notify('Work: view PR: ' .. (result.stdout or ''), vim.log.levels.INFO)
        else
          vim.notify(
            "Work: failed to view PR using command '"
              .. table.concat(cmd, ' ')
              .. "' with error: "
              .. (result.stderr or ''),
            vim.log.levels.ERROR
          )
        end

        return
      end

      -- create a PR
      local tracking_branch_result = vim
        .system({ 'git', 'rev-parse', '--abbrev-ref', '--symbolic-full-name', '@{u}' }, {
          text = true,
          stderr = false,
        })
        :wait()

      -- gh CLI expects the branch name without the remote when passed to gh pr create --base
      -- https://github.com/cli/cli/issues/5465
      local tracking_branch = nil
      if tracking_branch_result.code == 0 then
        local full_branch = vim.trim(tracking_branch_result.stdout)
        -- extract branch name part after the slash (e.g., "master" from "upstream/master")
        tracking_branch = full_branch:match('[^/]+$')
      end

      local cmd = { 'gh', 'pr', 'create', '--fill-first' }

      -- Add the base argument if tracking branch exists
      if tracking_branch then
        table.insert(cmd, '--base')
        table.insert(cmd, tracking_branch)
      end

      -- Add any additional args passed to the function like `--web` or `--reviewers`
      if #args >= 2 then -- strip 'view/create' subcommand arg
        for _, arg in ipairs(vim.list_slice(args, 2)) do
          table.insert(cmd, arg)
        end
      end

      local result = vim.system(cmd, { text = true }):wait()
      if result.code == 0 then
        vim.notify('Work: created PR: ' .. (result.stdout or ''), vim.log.levels.INFO)
      else
        vim.notify(
          "Work: failed to create PR using command '"
            .. table.concat(cmd, ' ')
            .. "' with error: "
            .. (result.stderr or ''),
          vim.log.levels.ERROR
        )
      end
    end,
    complete = function()
      return { 'create', 'view' }
    end,
  },
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
      vim.fn.mkdir(issue_dir(issue_nr), 'p')
      if vim.fn.filereadable(issue_markdown(issue_nr)) == 0 then
        local file = io.open(issue_markdown(issue_nr), 'w')
        if file then
          local header = '# [' .. issue_nr .. '](' .. issue_jira(issue_nr) .. ')'
          file:write(header)
          file:write('\n')
          file:close()
        end
      end

      os.remove(current_issue_link)
      if not vim.uv.fs_symlink(issue_dir(issue_nr), current_issue_link, { dir = true }) then
        vim.notify(
          'Work: failed to symlink the issue ' .. issue_nr .. ' dir to ' .. current_issue_link,
          vim.log.levels.ERROR
        )
      end

      set_issue_details(issue_nr)
      vim.cmd('edit ' .. issue_markdown(issue_nr))
      vim.api.nvim_buf_set_mark(0, 'W', 1, 0, {})
    end,
    -- Show existing issue numbers as completion options
    complete = function(subcmd_arg_lead)
      return vim
        .iter(vim.fs.dir(issues_dir, { depth = 1, follow = false }))
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

-- Return a new DHIS2 UID as defined by
-- https://github.com/dhis2/dhis2-core/blob/d2d5028d9a935fe5c85f9394d8ca0cd39dc8bdd8/dhis-2/dhis-api/src/main/java/org/hisp/dhis/common/CodeGenerator.java#L64
---@return string DHIS2 UID
M.uid = function()
  local digits = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }
  -- stylua: ignore start
  local alphabet = {
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',
    'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r',
    's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
    'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R',
    'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  }
  -- stylua: ignore end
  local alphanumeric = { unpack(alphabet), unpack(digits) }
  local first = alphabet[math.random(1, #alphabet)]
  local uid = first
  for _ = 1, 10, 1 do
    uid = uid .. alphanumeric[math.random(1, #alphanumeric)]
  end
  return uid
end

return M

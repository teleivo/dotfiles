-- My plugin for Graphviz DOT files.
-- See https://github.com/teleivo/dot/tree/main/cmd/inspect

---@class DotSubCommands
---@field impl fun(args:string[], opts: table) the command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) command completions callback, taking the lead of the subcommand's arguments

local inspect_buf = nil
local inspect_win = nil
local source_buf = nil
local ns_id = vim.api.nvim_create_namespace('DotInspectHighlight')

--- Parse position attribute from current line in inspect buffer
--- Looks for (@ start-line start-col end-line end-col) pattern
---@return table|nil {start_line, start_col, end_line, end_col} or nil if not found
local function parse_position_attr()
  if not inspect_buf or not vim.api.nvim_buf_is_valid(inspect_buf) then
    return nil
  end

  if not inspect_win or not vim.api.nvim_win_is_valid(inspect_win) then
    return nil
  end

  local cursor = vim.api.nvim_win_get_cursor(inspect_win)
  local line_num = cursor[1] - 1 -- Convert to 0-indexed
  local line = vim.api.nvim_buf_get_lines(inspect_buf, line_num, line_num + 1, false)[1]

  if not line then
    return nil
  end

  -- Match (@ start-line start-col end-line end-col)
  -- Parser outputs 1-indexed positions (inclusive), convert to 0-indexed for Neovim
  -- Start positions: subtract 1 from both line and col
  -- End col: keep as-is (parser's inclusive end becomes Neovim's exclusive end)
  local sl, sc, el, ec = line:match('%(@ (%d+) (%d+) (%d+) (%d+)%)')
  if sl and sc and el and ec then
    return {
      start_line = tonumber(sl) - 1,
      start_col = tonumber(sc) - 1,
      end_line = tonumber(el) - 1,
      end_col = tonumber(ec),  -- Don't subtract 1 for end_col
    }
  end

  return nil
end

--- Highlight the corresponding range in source buffer
local function highlight_source_range()
  if not source_buf or not vim.api.nvim_buf_is_valid(source_buf) then
    return
  end

  -- Clear previous highlights
  vim.api.nvim_buf_clear_namespace(source_buf, ns_id, 0, -1)

  local pos = parse_position_attr()
  if not pos then
    return
  end

  -- Positions from parser are 0-indexed, which matches Neovim API
  -- Add extmark for the range
  vim.api.nvim_buf_set_extmark(source_buf, ns_id, pos.start_line, pos.start_col, {
    end_line = pos.end_line,
    end_col = pos.end_col,
    hl_group = 'Visual',
    strict = false,
  })
end

--- Create a scratch buffer for the inspect output
---@return integer buf
local function create_scratch_buf()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].buflisted = false
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  return buf
end

--- Update the inspect buffer with the parsed AST
local function update_inspect()
  if not inspect_buf or not vim.api.nvim_buf_is_valid(inspect_buf) then
    return
  end
  if not source_buf or not vim.api.nvim_buf_is_valid(source_buf) then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(source_buf, 0, -1, false)
  local content = table.concat(lines, '\n')

  local result = vim.system({
    'go',
    'run',
    '.',
    'inspect',
    'tree',
    '-format',
    'scheme',
  }, {
    cwd = vim.env.HOME .. '/code/dot/cmd/dotx',
    stdin = content,
    text = true,
  }):wait()

  local output_lines = {}
  if result.code == 0 and result.stdout then
    output_lines = vim.split(result.stdout, '\n', { trimempty = true })
  elseif result.stderr and result.stderr ~= '' then
    output_lines = vim.split(result.stderr, '\n', { trimempty = true })
  else
    output_lines = { 'Parse error' }
  end

  vim.bo[inspect_buf].modifiable = true
  vim.api.nvim_buf_set_lines(inspect_buf, 0, -1, false, output_lines)
  vim.bo[inspect_buf].modifiable = false
end

--- Close the inspect window and clean up
local function close_inspect()
  if inspect_win and vim.api.nvim_win_is_valid(inspect_win) then
    vim.api.nvim_win_close(inspect_win, true)
  end
  -- Clear highlights from source buffer
  if source_buf and vim.api.nvim_buf_is_valid(source_buf) then
    vim.api.nvim_buf_clear_namespace(source_buf, ns_id, 0, -1)
  end
  inspect_win = nil
  inspect_buf = nil
  source_buf = nil
end

--- Open the inspect split
local function open_inspect()
  -- Close existing inspect window if open
  if inspect_win and vim.api.nvim_win_is_valid(inspect_win) then
    close_inspect()
    return
  end

  source_buf = vim.api.nvim_get_current_buf()
  inspect_buf = create_scratch_buf()

  -- Open vertical split on the right
  vim.cmd('vsplit')
  inspect_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(inspect_win, inspect_buf)

  -- Set buffer name
  vim.api.nvim_buf_set_name(inspect_buf, 'Dot://Inspect')

  -- Set filetype for syntax highlighting
  vim.bo[inspect_buf].filetype = 'scheme'

  -- Go back to source window
  vim.cmd('wincmd p')

  -- Initial update
  update_inspect()

  -- Set up autocmd to update on text changes (like :InspectTree)
  local group = vim.api.nvim_create_augroup('DotInspect', { clear = true })
  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = group,
    buffer = source_buf,
    callback = update_inspect,
  })

  -- Set up cursor tracking in inspect buffer for source highlighting
  vim.api.nvim_create_autocmd('CursorMoved', {
    group = group,
    buffer = inspect_buf,
    callback = highlight_source_range,
  })

  -- Clean up when inspect buffer is closed
  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group,
    buffer = inspect_buf,
    callback = function()
      if source_buf and vim.api.nvim_buf_is_valid(source_buf) then
        vim.api.nvim_buf_clear_namespace(source_buf, ns_id, 0, -1)
      end
      inspect_win = nil
      inspect_buf = nil
      source_buf = nil
      vim.api.nvim_del_augroup_by_name('DotInspect')
    end,
  })
end

---@type table<string, DotSubCommands>
local subcommands = {
  inspect = {
    impl = function()
      open_inspect()
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
    vim.notify('Dot: unknown command: ' .. subcommand_key, vim.log.levels.ERROR)
    return
  end

  subcommand.impl(args, opts)
end

vim.api.nvim_create_user_command('Dot', cmd, {
  nargs = '+',
  desc = 'Graphviz DOT development commands',
  complete = function(arg_lead, cmdline, _)
    -- get the subcommand
    local subcmd_key, subcmd_arg_lead = cmdline:match("^['<,'>]*Dot[!]*%s(%S+)%s(.*)$")
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
    if cmdline:match("^['<,'>]*Dot[!]*%s+%w*$") then
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

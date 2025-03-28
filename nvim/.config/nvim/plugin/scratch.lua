--- Open scratch buffer with code in given range. The buffers filetype is set via the filetype of
--- the file the range was selected from or by passing the filetype as the first command argument.
--- The command supports modifiers like topleft/botright/.. or tab. Refer to the ':help' on how to
--- combine them with counts and ranges.
--- Examples
--- :Scratch
--- :'<,'>Scratch
--- :'<,'>Scratch!
--- :3tab '<,'>Scratch
--- :botright '<,'>Scratch
--- :vertical Scratch foo.json
vim.api.nvim_create_user_command('Scratch', function(opts)
  local current_buf = 0
  local bufname_prefix = 'my-scratch://'

  -- the scratch buffer name is either defined by the range or the command arg
  local scratch_bufname
  if opts.range > 0 and opts.args == '' then
    -- compose the scratch buffer name from the current buffer name and a scratch prefix
    local current_bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(current_buf), ':p:.')
    scratch_bufname = bufname_prefix .. current_bufname
  elseif opts.args ~= '' then
    scratch_bufname = bufname_prefix .. opts.args
  end

  local scratch_buf = -1
  if scratch_bufname then
    scratch_buf = vim.fn.bufnr(scratch_bufname)
  end

  if scratch_buf ~= -1 and not opts.bang then
    vim.notify(
      'Buffer with name '
        .. scratch_bufname
        .. ' already exists. Invoke command with bang to override it!',
      vim.log.levels.ERROR
    )
    return
  end

  if scratch_buf == -1 then
    scratch_buf = vim.api.nvim_create_buf(true, true)
    if scratch_bufname then
      vim.api.nvim_buf_set_name(scratch_buf, scratch_bufname)
    end
  end

  if opts.range > 0 then
    local current_filetype = vim.api.nvim_get_option_value('filetype', { buf = current_buf })
    vim.api.nvim_set_option_value('filetype', current_filetype, { buf = scratch_buf })

    -- set the scratch buffer text to the selected range
    local lines = vim.api.nvim_buf_get_lines(current_buf, opts.line1 - 1, opts.line2, false)
    vim.api.nvim_buf_set_lines(scratch_buf, 0, -1, false, lines)
  end

  -- Set the filetype using the cmd arg suffix even if the scratch is filled from a current buffers
  -- range. This allows me to put a range of code using a different language from a markdown into a
  -- scratch. I could use treesitter for it but this is easier to accomplish.
  if opts.args ~= '' then
    local filetype = vim.fn.fnamemodify(scratch_bufname, ':e')
    if filetype then
      if filetype == 'md' then
        filetype = 'markdown'
      end
      vim.api.nvim_set_option_value('filetype', filetype, { buf = scratch_buf })
    end
  end

  if opts.smods.tab ~= -1 then
    vim.cmd(opts.smods.tab .. 'tabnew')
  elseif opts.smods.vertical then
    vim.cmd('vertical split')
  elseif opts.smods.split ~= '' then
    vim.cmd(opts.smods.split .. ' split')
  end

  vim.api.nvim_set_current_buf(scratch_buf)
end, {
  desc = 'Create a scratch buffer of a given filetype',
  nargs = '?',
  range = true,
  bang = true,
})

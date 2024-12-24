-- TODO support opening scratch in splits or tab, how to combine the cmd with modifiers
-- TODO set a bufname?
vim.api.nvim_create_user_command('Scratch', function(opts)
  local scratch_buf = vim.api.nvim_create_buf(true, true)

  if opts.range > 0 then
    local current_buf = 0

    -- set the scratch buffer name and filetype on the current buffer
    local current_bufname = vim.api.nvim_buf_get_name(current_buf)
    local scratch_bufname = 'scratch-' .. current_bufname
    vim.api.nvim_buf_set_name(scratch_buf, scratch_bufname)

    local current_filetype = vim.api.nvim_get_option_value('filetype', { buf = current_buf })
    vim.api.nvim_set_option_value('filetype', current_filetype, { buf = scratch_buf })

    -- set the scratch buffer text to the selected range
    local lines = vim.api.nvim_buf_get_lines(current_buf, opts.line1 - 1, opts.line2, false)
    vim.api.nvim_buf_set_lines(scratch_buf, 0, -1, false, lines)
  end

  if opts.args ~= '' then
    local filetype = opts.args
    vim.api.nvim_set_option_value('filetype', filetype, { buf = scratch_buf })
  end

  vim.api.nvim_set_current_buf(scratch_buf)
end, {
  desc = 'Create a scratch buffer of a given filetype',
  nargs = '?',
  range = true,
  bang = false,
})

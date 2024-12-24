-- TODO support opening scratch in splits or tab, how to combine the cmd with modifiers
-- TODO support range and paste range into scratch
-- TODO set a bufname?
vim.api.nvim_create_user_command('Scratch', function(opts)
  local buf = vim.api.nvim_create_buf(true, true)
  if opts.args ~= '' then
    local filetype = opts.args
    vim.api.nvim_set_option_value('filetype', filetype, { buf = buf })
  end
  vim.api.nvim_set_current_buf(buf)
end, {
  desc = 'Create a scratch buffer of a given filetype',
  nargs = '?',
  range = false,
  bang = false,
})

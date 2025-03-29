local to_vim_filetype = setmetatable({
  md = 'markdown',
}, {
  __index = function(_, key)
    return key
  end,
})

--- Open scratch buffer with code in given range. The buffers filetype is set via the filetype of
--- the file the range was selected from or by passing the filetype as the first command argument.
--- The command supports modifiers like topleft/botright/.. or tab. Refer to the ':help' on how to
--- combine them with counts and ranges.
---
--- The file will be written to disk in a temp directory. This is for example needed by the Go
--- toolchain.
---
--- The buffer is not actually a vim scratch buffer. Making it a scratch buffer makes the buffer not
--- writable which I need as explained before. The buffer options are set so that vim does not annoy
--- about unwritten changes. The temp file will be cleaned up by the OS.
---
--- Examples
--- :Scratch
--- :'<,'>Scratch
--- :'<,'>Scratch!
--- :3tab '<,'>Scratch
--- :botright '<,'>Scratch
--- :vertical Scratch foo.json
--- TODO the param should be of type vim.api.keyset.user_command but that definition is incomplete
--- @param opts table? Optional `command-attributes`.
vim.api.nvim_create_user_command('Scratch', function(opts)
  opts = opts or {}
  local current_buf = 0

  -- the scratch buffer name suffix is either defined by the range or the command arg
  local bufname_suffix
  if opts.range > 0 and opts.args == '' then
    -- compose the scratch buffer name from the current buffer name and a scratch prefix
    bufname_suffix = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(current_buf), ':p:.')
  elseif opts.args ~= '' then
    bufname_suffix = opts.args
  end

  local scratch_bufname = vim.fn.tempname() .. '-my-scratch-' .. bufname_suffix
  local scratch_bufnr = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(scratch_bufnr, scratch_bufname)

  -- configure buffer options for a writable scratch buffer
  vim.bo[scratch_bufnr].buftype = '' -- make it a normal file buffer (writable)
  vim.bo[scratch_bufnr].buflisted = true -- make it listed in buffer lists
  vim.bo[scratch_bufnr].swapfile = false -- avoid "swap exists" prompts
  vim.bo[scratch_bufnr].modified = false -- start as unmodified
  -- don't prompt about unsaved changes when leaving buffer
  vim.bo[scratch_bufnr].bufhidden = 'hide'

  if opts.range > 0 then
    vim.bo[scratch_bufnr].filetype = vim.bo[current_buf].filetype

    -- set the scratch buffer text to the selected range
    local lines = vim.api.nvim_buf_get_lines(current_buf, opts.line1 - 1, opts.line2, false)
    vim.api.nvim_buf_set_lines(scratch_bufnr, 0, -1, false, lines)
  end

  -- Set the filetype using the cmd arg suffix even if the scratch is filled from a current buffers
  -- range. This allows me to put a range of code using a different language from a markdown into a
  -- scratch. I could use treesitter for it but this is easier to accomplish.
  if opts.args ~= '' then
    local filetype = vim.fn.fnamemodify(scratch_bufname, ':e')
    vim.bo[scratch_bufnr].filetype = to_vim_filetype[filetype]
  end

  if opts.smods.tab ~= -1 then
    vim.cmd(opts.smods.tab .. 'tabnew')
  elseif opts.smods.vertical then
    vim.cmd('vertical split')
  elseif opts.smods.split ~= '' then
    vim.cmd(opts.smods.split .. ' split')
  end

  vim.api.nvim_set_current_buf(scratch_bufnr)

  -- autocommand to automatically save the buffer when leaving it to avoid getting prompted
  vim.api.nvim_create_autocmd({ 'BufLeave', 'WinLeave', 'FocusLost' }, {
    buffer = scratch_bufnr,
    callback = function()
      if vim.api.nvim_buf_is_valid(scratch_bufnr) then
        vim.api.nvim_buf_call(scratch_bufnr, function()
          vim.cmd('silent! write')
        end)
      end
    end,
  })

  -- initial write
  vim.api.nvim_buf_call(scratch_bufnr, function()
    vim.cmd('silent! write')
  end)
end, {
  desc = 'Create a scratch buffer of a given filetype',
  nargs = '?',
  range = true,
  bang = true,
})

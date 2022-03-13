local api = vim.api

local M = {}

require('lint').linters_by_ft = {
  go = { 'codespell', 'golangcilint' },
  lua = { 'codespell', 'luacheck' },
  sh = { 'shellcheck' },
  gitcommit = { 'codespell' },
}

local group = vim.api.nvim_create_augroup('my_lint', { clear = true })

function M.enable_lint()
  if not require('lint').linters_by_ft[vim.bo.filetype] then
    return
  end

  local bufnr = api.nvim_get_current_buf()
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
    callback = function()
      require('lint').try_lint()
    end,
    buffer = bufnr,
    group = group,
  })
end

return M

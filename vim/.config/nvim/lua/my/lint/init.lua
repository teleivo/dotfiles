local api = vim.api

local M = {}

require('lint').linters_by_ft = {
  go = { 'codespell', 'golangcilint' },
  lua = { 'codespell', 'luacheck' },
  sh = { 'shellcheck' },
  gitcommit = { 'codespell' },
}

function M.enable_lint()
  if not require('lint').linters_by_ft[vim.bo.filetype] then
    return
  end
  local bufnr = api.nvim_get_current_buf()
  vim.cmd('augroup lint')
  vim.cmd('au!')
  vim.cmd(string.format("au BufWritePost <buffer=%d> lua require'lint'.try_lint()", bufnr))
  vim.cmd(string.format("au BufEnter <buffer=%d> lua require'lint'.try_lint()", bufnr))
  vim.cmd('augroup end')
end

return M

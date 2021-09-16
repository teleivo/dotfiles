local jdtls = require('jdtls')
local lsp_key_mappings = require('my.lsp.mappings')
local M = {}

local key_mappings = {
  {'n','<A-o>',[[<cmd>lua require('jdtls').organize_imports()<cr>]]},
  {'n','crv',[[<cmd>lua require('jdtls').extract_variable()<cr>]]},
  {'v','crv',[[<esc><cmd>lua require('jdtls').extract_variable(true)<cr>]]},
  {'n','crc',[[<cmd>lua require('jdtls').extract_constant()<cr>]]},
  {'v','crc',[[<esc><cmd>lua require('jdtls').extract_constant(true)<cr>]]},
  {'v','crm',[[<esc><cmd>lua require('jdtls').extract_method(true)<cr>]]},
}

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap = true, silent = true }
  -- TODO only add key map if the LSP has the capability see https://github.com/mfussenegger/dotfiles/blob/c878895cbda5060159eb09ec1d3e580fd407b731/vim/.config/nvim/lua/me/lsp/conf.lua#L51
  -- find out what an LSP can with
  -- lua print(vim.inspect(vim.lsp.protocol.make_client_capabilities())
  -- TODO make it so the mappings here override potential mappings already
  -- defined in the LSP?
  -- TODO concatenate lsp key mappings and the ones from here
  for _, mappings in pairs(lsp_key_mappings) do
    local mode, lhs, rhs = unpack(mappings)
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
  end
  for _, mappings in pairs(key_mappings) do
    local mode, lhs, rhs = unpack(mappings)
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
  end
end

function M.start_jdt()
  local root_markers = {'gradlew', '.git', 'pom.xml', 'mvnw'}
  local root_dir = require('jdtls.setup').find_root(root_markers)
  local home = os.getenv('HOME')
  local workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
  local config = {
    cmd = {'java-lsp', workspace_folder},
    root_dir = root_dir,
    on_attach = on_attach,
  }
  jdtls.start_or_attach(config)
end

return M

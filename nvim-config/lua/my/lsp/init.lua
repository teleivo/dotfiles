local nvim_lsp = require('lspconfig')
local key_mappings = require('my.lsp.mappings').key_mappings

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap = true, silent = true }
  -- TODO only add key map if the LSP has the capability see https://github.com/mfussenegger/dotfiles/blob/c878895cbda5060159eb09ec1d3e580fd407b731/vim/.config/nvim/lua/me/lsp/conf.lua#L51
  -- find out what an LSP can with
  -- lua print(vim.inspect(vim.lsp.protocol.make_client_capabilities())
  for _, mappings in pairs(key_mappings) do
    local mode, lhs, rhs = unpack(mappings)
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
  end
end

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- vim-go installs and updates gopls. lsp-config starts and configures the lsp
-- and connects neovims lsp client to it. disabled gopls usage in vim-go to get
-- a better/unified lsp experience accross languages
-- available analyzers https://github.com/golang/tools/blob/master/gopls/doc/analyzers.md
require('lspconfig').gopls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      gopls = {
        gofumpt = true,
        analyses = {
          nilness = true,
          unusedparams = true,
        },
        staticcheck = true,
      },
    },
}

-- Note that this will also be used for the Java LSP jdtls
vim.cmd([[
    sign define LspDiagnosticsSignError text=● texthl=LspDiagnosticsSignError linehl= numhl=
    sign define LspDiagnosticsSignWarning text=● texthl=LspDiagnosticsSignWarning linehl= numhl=
    sign define LspDiagnosticsSignInformation text=ℹ️ texthl=LspDiagnosticsSignInformation linehl= numhl=
    sign define LspDiagnosticsSignHint text=💡️ texthl=LspDiagnosticsSignHint linehl= numhl=
]])

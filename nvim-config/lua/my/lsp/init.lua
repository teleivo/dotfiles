local nvim_lsp = require('lspconfig')

-- find out what an LSP can with
-- lua print(vim.inspect(vim.lsp.protocol.make_client_capabilities())
local key_mappings = {
  {'n', 'gq', '<cmd>lua vim.lsp.buf.formatting()<cr>'},
  -- range formatting does not seem to work with gopls
  {'v', 'gq', '<esc><cmd>lua vim.lsp.buf.range_formatting()<cr>'},
  {'n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>'},
  {'n', 'gD', '<cmd>lua vim.lsp.buf.type_definition()<cr>'},
  {'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>'},
  {'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>'},
  {'n', 'K', '<cmd>lua vim.lsp.buf.hover()<Cr>'},
  {'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>'},
  {'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>'},
  {'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>'},
  {'n', '<leader>dq', '<cmd>lua vim.lsp.diagnostic.set_qflist()<cr>'},
  {'n', '<leader>dl', '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>'},
  {'n', '<leader>ds', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>'},
  {'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>'},
  {'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>'},
  -- search symbols using "f" since all my telescope mappings are prefixed with "f"
  {'n', '<leader>fs', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]]}
}

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap = true, silent = true }
  -- TODO only add key map if the LSP has the capability see https://github.com/mfussenegger/dotfiles/blob/c878895cbda5060159eb09ec1d3e580fd407b731/vim/.config/nvim/lua/me/lsp/conf.lua#L51
  for _, mappings in pairs(key_mappings) do
    local mode, lhs, rhs = unpack(mappings)
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
  end
end

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

vim.cmd([[
    sign define LspDiagnosticsSignError text=● texthl=LspDiagnosticsSignError linehl= numhl=
    sign define LspDiagnosticsSignWarning text=● texthl=LspDiagnosticsSignWarning linehl= numhl=
    sign define LspDiagnosticsSignInformation text=ℹ️ texthl=LspDiagnosticsSignInformation linehl= numhl=
    sign define LspDiagnosticsSignHint text=💡️ texthl=LspDiagnosticsSignHint linehl= numhl=
]])

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

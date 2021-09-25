local key_mappings = require('my.lsp.mappings')

local on_attach = function(_, bufnr)
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

local sumneko_root_path = vim.fn.getenv 'HOME' .. '/code/lsp/sumneko/lua-language-server'
local sumneko_binary = sumneko_root_path .. '/bin/Linux/lua-language-server'

-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

require('lspconfig').sumneko_lua.setup {
  cmd = { sumneko_binary, '-E', sumneko_root_path .. '/main.lua' },
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file('', true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

vim.cmd([[
  highlight! link LspDiagnosticsVirtualTextError DiagnosticError
  highlight! link LspDiagnosticsVirtualTextWarning DiagnosticWarn
  highlight! link LspDiagnosticsVirtualTextInfo DiagnosticInfo
  highlight! link LspDiagnosticsVirtualTextHint DiagnosticHint
]])
vim.fn.sign_define("LspDiagnosticsSignError", {text = "", numhl = "CocErrorSign"})
vim.fn.sign_define("LspDiagnosticsSignWarning", {text = "", numhl = "CocWarningSign"})
vim.fn.sign_define("LspDiagnosticsSignInformation", {text = "", numhl = "CocInfoSign"})
vim.fn.sign_define("LspDiagnosticsSignHint", {text = "", numhl = "CocHintSign"})

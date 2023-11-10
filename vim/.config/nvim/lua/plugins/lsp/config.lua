local key_mappings = require('plugins.lsp.mappings')

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { buffer = bufnr, noremap = true, silent = true }
  -- TODO only add key map if the LSP has the capability see https://github.com/mfussenegger/dotfiles/blob/c878895cbda5060159eb09ec1d3e580fd407b731/vim/.config/nvim/lua/me/lsp/conf.lua#L51
  -- find out what an LSP can with
  -- lua print(vim.inspect(vim.lsp.protocol.make_client_capabilities())
  for _, mappings in pairs(key_mappings) do
    local mode, lhs, rhs = unpack(mappings)
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- TODO does not work anymore
  if client.server_capabilities.documentHighlightProvider then
    local group = vim.api.nvim_create_augroup('my_lsp', { clear = true })
    vim.api.nvim_create_autocmd('CursorHold', {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.document_highlight()
      end,
      group = group,
    })
    vim.api.nvim_create_autocmd('CursorMoved', {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.clear_references()
      end,
      group = group,
    })
  end
end

-- TODO finish adding capabilities after nvim-cmp is workin again
-- nvim-cmp supports additional completion capabilities
-- local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- vim-go installs and updates gopls. lsp-config starts and configures the lsp
-- and connects neovims lsp client to it. disabled gopls usage in vim-go to get
-- a better/unified lsp experience across languages
-- available analyzers https://github.com/golang/tools/blob/master/gopls/doc/analyzers.md
require('lspconfig').gopls.setup({
  on_attach = on_attach,
  -- capabilities = capabilities,
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
})

require('lspconfig').lua_ls.setup({
  on_attach = on_attach,
  -- capabilities = capabilities,
  settings = {
    Lua = {
      telemetry = {
        enable = false,
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = 'space',
          indent_size = '2',
        },
      },
    },
  },
})

-- autoformat
local group = vim.api.nvim_create_augroup('my_lua', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.lua',
  callback = function()
    vim.lsp.buf.format()
  end,
  group = group,
})

require('lspconfig').yamlls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    yaml = {
      format = {
        enable = true,
      },
      editor = {
        formatOnType = true,
      },
      schemas = {
        ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
        ['https://json.schemastore.org/dependabot-2.0.json'] = '/.github/dependabot.yml',
        ['https://json.schemastore.org/golangci-lint.json'] = { '.golangci.yml', '.golangci.yaml' },
        ['https://goreleaser.com/static/schema.json'] = '.goreleaser.yml',
        ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = 'docker-compose*.yml',
        ['https://raw.githubusercontent.com/ansible-community/schemas/main/f/ansible-tasks.json'] = '/playbooks/**/tasks/*.yml',
        ['https://raw.githubusercontent.com/ansible-community/schemas/main/f/ansible-playbook.json'] = '/playbooks/*.yml',
      },
    },
  },
})

require('lspconfig').jsonls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

require('lspconfig').bashls.setup({})

vim.cmd([[
  highlight! link LspDiagnosticsVirtualTextError DiagnosticError
  highlight! link LspDiagnosticsVirtualTextWarning DiagnosticWarn
  highlight! link LspDiagnosticsVirtualTextInfo DiagnosticInfo
  highlight! link LspDiagnosticsVirtualTextHint DiagnosticHint
]])
vim.fn.sign_define('LspDiagnosticsSignError', { text = '', numhl = 'CocErrorSign' })
vim.fn.sign_define('LspDiagnosticsSignWarning', { text = '', numhl = 'CocWarningSign' })
vim.fn.sign_define('LspDiagnosticsSignInformation', { text = '', numhl = 'CocInfoSign' })
vim.fn.sign_define('LspDiagnosticsSignHint', { text = '', numhl = 'CocHintSign' })

-- show docs with a rounded border so its easier to distinguish from the rest of the code
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'rounded',
})
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = 'rounded',
})

local servers = {
  bashls = {},
  jsonls = {},
  lua_ls = {
    Lua = {
      workspace = {
        checkThirdParty = false,
      },
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
  marksman = {},
  -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
  -- available analyzers https://github.com/golang/tools/blob/master/gopls/doc/analyzers.md
  gopls = {
    gofumpt = true,
    analyses = {
      nilness = true,
      unusedparams = true,
    },
    staticcheck = true,
  },
  yamlls = {
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
}

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })

  -- highlight currently selected symbol
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

-- nvim-cmp supports additional completion capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- autoformat
local lua_group = vim.api.nvim_create_augroup('my_lua', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.lua',
  callback = function()
    vim.lsp.buf.format()
  end,
  group = lua_group,
})

-- from https://github.com/golang/tools/blob/master/gopls/doc/vim.md#imports
local function goimports(wait_ms)
  local params = vim.lsp.util.make_range_params()
  params.context = { only = { 'source.organizeImports' } }
  local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, wait_ms)
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        vim.lsp.util.apply_workspace_edit(r.edit, 'utf-16')
      else
        vim.lsp.buf.execute_command(r.command)
      end
    end
  end
end

-- autoformat and organize imports
local go_group = vim.api.nvim_create_augroup('my_go', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function()
    vim.lsp.buf.format()
    goimports(5000)
  end,
  group = go_group,
})

return {
  {
    'neovim/nvim-lspconfig',
    -- alternative would be to only add them if the LSP has the capability see https://github.com/mfussenegger/dotfiles/blob/c878895cbda5060159eb09ec1d3e580fd407b731/vim/.config/nvim/lua/me/lsp/conf.lua#L51
    keys = {
      {
        '<leader>cr',
        function()
          return require('telescope.builtin').lsp_references()
        end,
      },
      {
        'gd',
        function()
          return require('telescope.builtin').lsp_definitions()
        end,
      },
      -- TODO do I need this one
      -- many servers do not implement this method, if it errors use definition
      { 'gD', vim.lsp.buf.declaration },
      {
        '<leader>ct',
        function()
          return require('telescope.builtin').lsp_type_definitions()
        end,
      },
      {
        '<leader>ci',
        function()
          return require('telescope.builtin').lsp_implementations()
        end,
      },
      -- search symbols using "f" since all my telescope mappings are prefixed with "f"
      {
        '<leader>fs',
        function()
          return require('telescope.builtin').lsp_document_symbols()
        end,
      },
      -- documentation
      {
        'K',
        vim.lsp.buf.hover,
      },
      {
        '<C-k>',
        vim.lsp.buf.signature_help,
        mode = { 'n', 'i' },
      },
      -- code actions and refactoring
      {
        '<leader>ca',
        vim.lsp.buf.code_action,
        mode = { 'n', 'v' },
      },
      {
        '<leader>rn',
        vim.lsp.buf.rename,
        mode = { 'n', 'v' },
      },
      -- diagnostics
      { '<leader>e', vim.diagnostic.open_float },
      { '[d', vim.diagnostic.goto_prev },
      { ']d', vim.diagnostic.goto_next },
    },
  },
  {
    'williamboman/mason.nvim',
    config = true,
    build = ':MasonUpdate',
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'folke/neodev.nvim',
      'neovim/nvim-lspconfig',
      'hrsh7th/nvim-cmp',
    },
    opts = {
      automatic_installation = true,
      ensure_installed = vim.tbl_keys(servers),
      handlers = {
        function(server_name)
          -- https://github.com/folke/neodev.nvim/issues/98#issuecomment-1778364644
          require('neodev').setup({
            library = {
              plugins = {
                'nvim-dap-ui',
              },
              types = true,
            },
          })
          require('lspconfig')[server_name].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
          })
        end,
      },
    },
  },
}

-- show docs with a rounded border so its easier to distinguish from the rest of the code
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'rounded',
})
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = 'rounded',
})

local servers = {
  -- jdtls is managed by nvim-jdtls and therefore not defined here
  -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jdtls
  bashls = {},
  denols = {},
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
        enable = false,
      },
      completion = {
        autorequire = true,
        callSnippet = 'Replace',
        keywordSnippet = 'Replace',
        postfix = '.',
        showParams = false,
      },
      hint = {
        enable = true,
        await = true,
      },
    },
  },
  marksman = {},
  -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
  gopls = {
    gopls = {
      gofumpt = true,
      usePlaceholders = true,
      linksInHover = 'gopls',
      hints = {
        compositeLiteralFields = true,
        constantValues = true,
      },
      -- verboseOutput = true, -- uncomment for debugging
      -- available analyzers https://github.com/golang/tools/blob/master/gopls/doc/analyzers.md
      analyses = {
        nilness = true,
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
  yamlls = {
    yaml = {
      format = {
        enable = true,
        bracketSpacing = false,
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
  -- enable inlay hints if supported
  -- for example https://github.com/golang/tools/blob/master/gopls/doc/settings.md#inlayhint
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true)
  end

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

  for _, mappings in pairs(require('my-lsp').keymaps) do
    local mode, lhs, rhs, opts = unpack(mappings)
    vim.keymap.set(
      mode,
      lhs,
      rhs,
      vim.tbl_deep_extend('error', opts, { buffer = bufnr, silent = true })
    )
  end
end

return {
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    config = true,
    build = ':MasonUpdate',
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
      'saghen/blink.cmp',
    },
    opts = {
      automatic_installation = false, -- done by ../mason-tool-installer.lua
      ensure_installed = vim.tbl_keys(servers), -- LSPs are managed here and installed via mason-lspconfig.nvim
      handlers = {
        function(server_name)
          require('lspconfig')[server_name].setup({
            capabilities = require('blink.cmp').get_lsp_capabilities(),
            on_attach = on_attach,
            settings = servers[server_name],
          })
        end,
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    lazy = true,
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
}

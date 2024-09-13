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
    },
  },
  marksman = {},
  -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
  gopls = {
    gofumpt = true,
    completion = {
      usePlaceholders = true,
    },
    linksInHover = 'gopls', -- TODO this does not seem to work/or I don't get what its supposed to do
    hints = { -- TODO this also does not work even if i enable hints in the LSP
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
end

-- nvim-cmp supports additional completion capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()

return {
  {
    'neovim/nvim-lspconfig',
    -- alternative would be to only add them if the LSP has the capability
    -- see https://github.com/mfussenegger/dotfiles/blob/c878895cbda5060159eb09ec1d3e580fd407b731/vim/.config/nvim/lua/me/lsp/conf.lua#L51
    keys = {
      {
        '<leader>cr',
        function()
          return require('telescope.builtin').lsp_references()
        end,
        desc = 'Search code references using LSP',
      },
      {
        'gd',
        function()
          return require('telescope.builtin').lsp_definitions()
        end,
        desc = 'Go to definition using LSP',
      },
      -- TODO do I need this one
      -- many servers do not implement this method, if it errors use definition
      { 'gD', vim.lsp.buf.declaration, desc = 'Go to declaration using LSP' },
      {
        '<leader>ct',
        function()
          return require('telescope.builtin').lsp_type_definitions()
        end,
        desc = 'Go to type definition using LSP',
      },
      {
        '<leader>ci',
        function()
          return require('telescope.builtin').lsp_implementations()
        end,
        desc = 'Search implementations using LSP (go to if there is only one)',
      },
      -- search symbols using "f" since all my telescope mappings are prefixed with "f"
      {
        '<leader>fs',
        function()
          return require('telescope.builtin').lsp_document_symbols()
        end,
        desc = 'Search symbols using LSP',
      },
      -- documentation
      {
        'K',
        vim.lsp.buf.hover,
        desc = 'Show documentation using LSP',
      },
      {
        '<C-k>',
        vim.lsp.buf.signature_help,
        mode = { 'n', 'i' },
        desc = 'Show signature help using LSP',
      },
      -- code actions and refactoring
      {
        '<leader>ca',
        vim.lsp.buf.code_action,
        mode = { 'n', 'v' },
        desc = 'Select an LSP code action',
      },
      {
        '<leader>rn',
        vim.lsp.buf.rename,
        mode = { 'n', 'v' },
        desc = 'Rename symbol using LSP',
      },
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
      automatic_installation = false, -- done by ../mason-tool-installer.lua
      ensure_installed = vim.tbl_keys(servers), -- LSPs are managed here and installed via mason-lspconfig.nvim
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

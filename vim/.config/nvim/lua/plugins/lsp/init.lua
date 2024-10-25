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
end

-- nvim-cmp supports additional completion capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()

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
      'hrsh7th/nvim-cmp',
    },
    opts = {
      automatic_installation = false, -- done by ../mason-tool-installer.lua
      ensure_installed = vim.tbl_keys(servers), -- LSPs are managed here and installed via mason-lspconfig.nvim
      handlers = {
        function(server_name)
          require('lspconfig')[server_name].setup({
            capabilities = capabilities,
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
    -- alternative would be to only add them if the LSP has the capability
    -- see https://github.com/mfussenegger/dotfiles/blob/c878895cbda5060159eb09ec1d3e580fd407b731/vim/.config/nvim/lua/me/lsp/conf.lua#L51
    keys = {
      {
        'grr',
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
        '<C-k>',
        vim.lsp.buf.signature_help,
        mode = { 'n', 'i' },
        desc = 'Show signature help using LSP',
      },
      {
        'grf',
        function()
          vim.lsp.buf.code_action({
            context = { only = { 'source.organizeImports' } },
            apply = true,
          })
          vim.lsp.buf.code_action({
            context = { only = { 'source.fixAll' } },
            apply = true,
          })
        end,
        desc = 'Organize imports and fix all using LSP',
      },
      {
        'grx',
        function()
          vim.lsp.buf.code_action({
            context = { only = { 'refactor.extract' } },
            apply = true,
          })
          -- TODO no way for me to know if and what action was applied. I would want to leave visual
          -- mode only when an action was actually applied. If not I want to be able to stay in
          -- visual mode to refine my selection
          -- https://github.com/neovim/neovim/issues/25259
          -- It would be great if the cursor would always be put on the extracted node. It does work
          -- for variables but not for functions. Not sure if that is the responsibility of the LSP.
          local esc = vim.api.nvim_replace_termcodes('<esc>', true, false, true)
          vim.api.nvim_feedkeys(esc, 'x', false)
        end,
        mode = { 'v' },
        desc = 'Extract visual selection into variable, function or method',
      },
    },
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {},
  },
}

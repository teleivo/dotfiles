local jdtls = require('jdtls')
-- local lsp_key_mappings = require('my.lsp.mappings')
local M = {}

-- TODO duplicated mappings from lspconfig extract them and merge with java specific ones
local key_mappings = {
  {
    'n',
    '<leader>cr',
    function()
      return require('telescope.builtin').lsp_references()
    end,
  },
  {
    'n',
    'gd',
    function()
      return require('telescope.builtin').lsp_definitions()
    end,
  },
  -- TODO do I need this one
  -- many servers do not implement this method, if it errors use definition
  { 'n', 'gD', vim.lsp.buf.declaration },
  {
    'n',
    '<leader>ct',
    function()
      return require('telescope.builtin').lsp_type_definitions()
    end,
  },
  {
    'n',
    '<leader>ci',
    function()
      return require('telescope.builtin').lsp_implementations()
    end,
  },
  -- search symbols using "f" since all my telescope mappings are prefixed with "f"
  {
    'n',
    '<leader>fs',
    function()
      return require('telescope.builtin').lsp_document_symbols()
    end,
  },
  -- documentation
  {
    'n',
    'K',
    vim.lsp.buf.hover,
  },
  {
    { 'n', 'i' },
    '<C-k>',
    vim.lsp.buf.signature_help,
  },
  -- code actions and refactoring
  {
    { 'n', 'v' },
    '<leader>ca',
    vim.lsp.buf.code_action,
  },
  {
    { 'n', 'v' },
    '<leader>rn',
    vim.lsp.buf.rename,
  },
  -- diagnostics
  { 'n', '<leader>e', vim.diagnostic.open_float },
  { 'n', '[d', vim.diagnostic.goto_prev },
  { 'n', ']d', vim.diagnostic.goto_next },
  {
    'n',
    '<A-o>',
    function()
      return require('jdtls').organize_imports()
    end,
  },
  {
    'n',
    '<leader>rv',
    function()
      return require('jdtls').extract_variable()
    end,
  },
  {
    'v',
    '<leader>rv',
    function()
      return require('jdtls').extract_variable(true)
    end,
  },
  {
    'n',
    '<leader>rc',
    function()
      return require('jdtls').extract_constant()
    end,
  },
  {
    'v',
    '<leader>rc',
    function()
      return require('jdtls').extract_constant(true)
    end,
  },
  {
    'v',
    '<leader>rm',
    function()
      return require('jdtls').extract_method(true)
    end,
  },
  -- debug
  {
    'n',
    '<leader>dt',
    function()
      return require('jdtls').test_class()
    end,
  },
  {
    'n',
    '<leader>dn',
    function()
      return require('jdtls').test_nearest_method()
    end,
  },
}

local on_attach = function(_, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { buffer = bufnr, silent = true }
  -- TODO only add key map if the LSP has the capability see https://github.com/mfussenegger/dotfiles/blob/c878895cbda5060159eb09ec1d3e580fd407b731/vim/.config/nvim/lua/me/lsp/conf.lua#L51
  -- find out what an LSP can with
  -- lua print(vim.inspect(vim.lsp.protocol.make_client_capabilities())
  -- TODO make it so the mappings here override potential mappings already
  -- defined in the LSP?
  -- TODO concatenate lsp key mappings and the ones from here
  -- for _, mappings in pairs(lsp_key_mappings) do
  --   local mode, lhs, rhs = unpack(mappings)
  --   vim.keymap.set(mode, lhs, rhs, opts)
  -- end
  for _, mappings in pairs(key_mappings) do
    local mode, lhs, rhs = unpack(mappings)
    vim.keymap.set(mode, lhs, rhs, opts)
  end
  -- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
  -- you make during a debug session immediately.
  -- Remove the option if you do not want that.
  jdtls.setup_dap({ hotcodereplace = 'auto' })
  jdtls.setup.add_commands()
end

function M.start_jdt()
  local root_markers = { 'gradlew', 'mvnw', '.git' }
  local root_dir = vim.fs.root(0, root_markers) or vim.fs.root(0, { 'pom.xml' })
  if not root_dir then
    return
  end
  local home = os.getenv('HOME')
  local workspace_folder = home .. '/.local/share/eclipse/' .. vim.fn.fnamemodify(root_dir, ':p:h:t')

  -- nvim-cmp supports additional completion capabilities
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  -- capabilities.workspace.configuration = true

  local extendedClientCapabilities = jdtls.extendedClientCapabilities
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  local bundles = {
    vim.fn.glob(
      home .. '/code/neovim/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar'
    ),
  }
  vim.list_extend(bundles, vim.split(vim.fn.glob(home .. '/code/neovim/vscode-java-test/server/*.jar'), '\n'))

  local config = {
    flags = {
      allow_incremental_sync = true,
    },
    cmd = {
      '/usr/lib/jvm/temurin-17-jdk-amd64/bin/java',
      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Dlog.protocol=true',
      '-Dlog.level=ALL',
      '-Xmx1g',
      '--add-modules=ALL-SYSTEM',
      '--add-opens',
      'java.base/java.util=ALL-UNNAMED',
      '--add-opens',
      'java.base/java.lang=ALL-UNNAMED',
      '-javaagent:' .. home .. '/.local/share/lombok/lombok.jar',
      '-jar',
      -- vim.fn.glob(
      --   home
      --   .. '/code/lsp/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository/plugins/org.eclipse.equinox.launcher_*.jar'
      -- ),
      vim.fn.glob(home .. '/code/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
      '-configuration',
      home .. '/code/jdtls/config_linux',
      '-data',
      workspace_folder,
    },
    handlers = {
      ['language/status'] = function(_, result)
        if string.find(result.message, '0%% Starting') then
          vim.api.nvim_command(':echohl Function | echo "Java LSP is starting" | echohl None')
        elseif string.find(result.message, 'ServiceReady') then
          vim.api.nvim_command(':echohl Function | echo "Java LSP is ready" | echohl None')
        end
      end,
    },
    root_dir = root_dir,
    settings = {
      java = {
        signatureHelp = { enabled = true },
        contentProvider = { preferred = 'fernflower' },
        format = {
          settings = {
            url = 'file:///' .. home .. '/code/eclipse-java-google-style.xml',
          },
        },
        saveActions = {
          organizeImports = true,
        },
        completion = {
          favoriteStaticMembers = {
            'org.junit.jupiter.api.Assertions.*',
            'org.hamcrest.MatcherAssert.assertThat',
            'org.hamcrest.Matchers.*',
            'org.hamcrest.CoreMatchers.*',
            'java.util.Objects.requireNonNull',
            'java.util.Objects.requireNonNullElse',
            'org.mockito.Mockito.*',
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
        configuration = {
          runtimes = {
            {
              name = 'JavaSE-11',
              path = '/usr/lib/jvm/temurin-11-jdk-amd64',
            },
            {
              name = 'JavaSE-17',
              path = '/usr/lib/jvm/temurin-17-jdk-amd64',
            },
          },
        },
      },
    },
    capabilities = capabilities,
    init_options = {
      extendedClientCapabilities = extendedClientCapabilities,
      bundles = bundles,
    },
    on_attach = on_attach,
  }
  config.on_init = function(client, _)
    client.notify('workspace/didChangeConfiguration', { settings = config.settings })
  end

  jdtls.start_or_attach(config)
end

-- local group = vim.api.nvim_create_augroup('my_java', { clear = true })
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   pattern = '*.java',
--   callback = function()
--     -- vim.lsp.buf.formatting()
--     jdtls.organize_imports()
--   end,
--   group = group,
-- })

return M

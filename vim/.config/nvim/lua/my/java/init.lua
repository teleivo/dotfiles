local jdtls = require('jdtls')
local lsp_key_mappings = require('my.lsp.mappings')
local M = {}

local key_mappings = {
  { 'n', '<A-o>', [[<cmd>lua require('jdtls').organize_imports()<cr>]] },
  { 'n', '<leader>rv', [[<cmd>lua require('jdtls').extract_variable()<cr>]] },
  { 'v', '<leader>rv', [[<esc><cmd>lua require('jdtls').extract_variable(true)<cr>]] },
  { 'n', '<leader>rc', [[<cmd>lua require('jdtls').extract_constant()<cr>]] },
  { 'v', '<leader>rc', [[<esc><cmd>lua require('jdtls').extract_constant(true)<cr>]] },
  { 'v', '<leader>rm', [[<esc><cmd>lua require('jdtls').extract_method(true)<cr>]] },
  -- debug
  { 'n', '<leader>dt', [[<esc><cmd>lua require('jdtls').test_class()<cr>]] },
  { 'n', '<leader>dn', [[<esc><cmd>lua require('jdtls').test_nearest_method()<cr>]] },
}

local on_attach = function(_, bufnr)
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
  -- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
  -- you make during a debug session immediately.
  -- Remove the option if you do not want that.
  jdtls.setup_dap({ hotcodereplace = 'auto' })
  jdtls.setup.add_commands()
end

function M.start_jdt()
  -- TODO is this causing an issue since in DHIS2 the root .git dir has no pom.
  -- Now with adding pom.xml is every subproject its own jdtls project?
  local root_markers = { 'gradlew', '.git', 'pom.xml', 'mvnw' }
  local root_dir = jdtls.setup.find_root(root_markers)
  local home = os.getenv('HOME')
  local workspace_folder = home .. '/.local/share/eclipse/' .. vim.fn.fnamemodify(root_dir, ':p:h:t')

  -- nvim-cmp supports additional completion capabilities
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
  capabilities.workspace.configuration = true

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
      '/usr/lib/jvm/temurin-11-jdk-amd64/bin/java',
      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Dlog.protocol=true',
      '-Dlog.level=ALL',
      '-Xms1g',
      '-javaagent:' .. home .. '/.local/share/lombok/lombok.jar',
      '-jar',
      vim.fn.glob(
        home
          .. '/code/lsp/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository/plugins/org.eclipse.equinox.launcher_*.jar'
      ),
      '-configuration',
      home .. '/code/lsp/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository/config_linux',
      '-data',
      workspace_folder,
      '--add-modules=ALL-SYSTEM',
      '--add-opens',
      'java.base/java.util=ALL-UNNAMED',
      '--add-opens',
      'java.base/java.lang=ALL-UNNAMED',
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
        -- TODO adapt to local path in repo once issue https://github.com/eclipse/eclipse.jdt.ls/pull/1893 is
        -- resolved
        format = {
          settings = {
            url = 'https://raw.githubusercontent.com/dhis2/dhis2-core/master/dhis-2/DHISFormatter.xml',
          },
        },
        completion = {
          favoriteStaticMembers = {
            'org.hamcrest.MatcherAssert.assertThat',
            'org.hamcrest.Matchers.*',
            'org.hamcrest.CoreMatchers.*',
            'org.junit.jupiter.api.Assertions.*',
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
              name = 'JavaSE-1.8',
              path = '/usr/lib/jvm/temurin-8-jdk-amd64',
            },
            {
              name = 'JavaSE-11',
              path = '/usr/lib/jvm/temurin-11-jdk-amd64',
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

vim.cmd([[
  augroup JAVA_LSP
    autocmd!
    autocmd BufWritePre *.java :silent! lua vim.lsp.buf.formatting()
    autocmd BufWritePre *.java :silent! lua require'jdtls'.organize_imports()
  augroup END
]])

return M

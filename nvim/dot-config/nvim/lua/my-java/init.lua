local M = {}

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
      vim.tbl_deep_extend('error', vim.F.if_nil(opts, {}), { buffer = bufnr, silent = true })
    )
  end
end

function M.start_jdt()
  local root_markers = { 'gradlew', 'mvnw', '.git' }
  local root_dir = vim.fs.root(0, root_markers) or vim.fs.root(0, { 'pom.xml' })
  if not root_dir then
    return
  end
  local home = os.getenv('HOME')
  local dotfiles = os.getenv('DOTFILES')
  local workspace_folder = home
    .. '/.local/share/eclipse/'
    .. vim.fn.fnamemodify(root_dir, ':p:h:t')

  -- nvim-cmp supports additional completion capabilities
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  -- capabilities.workspace.configuration = true

  local extendedClientCapabilities = require('jdtls').extendedClientCapabilities
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  local bundles = {
    vim.fn.glob(
      home
        .. '/code/neovim/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar'
    ),
  }
  vim.list_extend(
    bundles,
    vim.split(vim.fn.glob(home .. '/code/neovim/vscode-java-test/server/*.jar'), '\n')
  )

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
        cleanup = {
          -- https://github.com/redhat-developer/vscode-java/blob/master/document/_java.learnMoreAboutCleanUps.md#java-clean-ups
          actions = {
            'addDeprecated',
            'addOverride',
            'instanceofPatternMatch',
            'invertEquals',
            'lambdaExpression',
            'lambdaExpressionFromAnonymousClass',
            'organizeImports',
            'stringConcatToTextBlock',
            'switchExpression',
            'tryWithResource',
          },
        },
        contentProvider = { preferred = 'fernflower' },
        format = {
          enabled = false,
        },
        saveActions = {
          cleanup = true,
          organizeImports = false,
        },
        -- referencesCodeLens = {
        --   enabled = true,
        -- },
        -- references = {
        --   includeDecompiledSources = true,
        -- },
        -- inlayHints = {
        --   parameterNames = {
        --     enabled = "all",
        --   },
        -- },
        completion = {
          favoriteStaticMembers = {
            'org.junit.jupiter.api.Assertions.*',
            'org.mockito.Mockito.*',
            'org.hamcrest.MatcherAssert.assertThat',
            'org.hamcrest.Matchers.*',
            'org.hamcrest.CoreMatchers.*',
            'java.util.Objects.requireNonNull',
            'java.util.Objects.requireNonNullElse',
          },
          filteredTypes = {
            'com.sun.*',
            'io.micrometer.shaded.*',
            'java.awt.*',
            'jdk.*',
            'org.jclouds.javax.*',
            'org.jetbrains.*',
            'sun.*',
          },
          postfix = true,
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
        settings = {
          url = dotfiles .. '/vim/.config/nvim/lua/my-java/settings.prefs',
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

  require('jdtls').start_or_attach(config)
end

return M

-- This is my plugin for development in Go.
-- Thank you to https://github.com/nvim-neorocks/nvim-best-practices ♥
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

local root_markers = { 'gradlew', 'mvnw', '.git' }
local root_dir = vim.fs.root(0, root_markers) or vim.fs.root(0, { 'pom.xml' })
if not root_dir then
  return
end
local home = os.getenv('HOME')
local dotfiles = os.getenv('DOTFILES')
local workspace_folder = home .. '/.local/share/eclipse/' .. vim.fn.fnamemodify(root_dir, ':p:h:t')

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
    '-Xmx4g',
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

---@class JavaSubCommands
---@field impl fun(args:string[], opts: table) the command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) command completions callback, taking the lead of the subcommand's arguments

-- TODO use nvim_buf_create_user_command? or is it ok if its a global user command.
---@type table<string, JavaSubCommands>
local subcommands = {
  test = {
    impl = function(args)
      local test
      if args[1] then
        local tests = require('my-java').find_tests()
        local set = {}
        for _, v in ipairs(tests) do
          set[v.name] = v
        end
        test = set[args[1]]
      end

      require('my-java').mvn_test(test)
    end,
    complete = function(subcmd_arg_lead)
      local tests = require('my-java').find_tests()
      if not tests then
        return {}
      end

      return vim
        .iter(tests)
        :map(function(test)
          return test.name
        end)
        :filter(function(arg)
          -- If the user has typed `:Java test testX`,
          -- this will match 'testX'
          return arg:find(subcmd_arg_lead) ~= nil
        end)
        :totable()
    end,
  },
}

---@param opts table :h lua-guide-commands-create
local function cmd(opts)
  local fargs = opts.fargs
  local subcommand_key = fargs[1]

  -- Get the subcommand's arguments, if any
  local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
  local subcommand = subcommands[subcommand_key]
  if not subcommand then
    vim.notify('Java: unknown command: ' .. subcommand_key, vim.log.levels.ERROR)
    return
  end

  subcommand.impl(args, opts)
end

vim.api.nvim_create_user_command('Java', cmd, {
  nargs = '+',
  desc = 'Command for development in Java',
  complete = function(arg_lead, cmdline, _)
    -- get the subcommand
    local subcmd_key, subcmd_arg_lead = cmdline:match("^['<,'>]*Java[!]*%s(%S+)%s(.*)$")
    if
      subcmd_key
      and subcmd_arg_lead
      and subcommands[subcmd_key]
      and subcommands[subcmd_key].complete
    then
      -- return subcommand completions
      return subcommands[subcmd_key].complete(subcmd_arg_lead)
    end

    -- check if cmdline is a subcommand
    if cmdline:match("^['<,'>]*Java[!]*%s+%w*$") then
      -- filter matching subcommands
      local subcommand_keys = vim.tbl_keys(subcommands)
      return vim
        .iter(subcommand_keys)
        :filter(function(key)
          return key:find(arg_lead) ~= nil
        end)
        :totable()
    end
  end,
  bang = false,
})

require('telescope').load_extension('test')

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

local capabilities = require('blink.cmp').get_lsp_capabilities()
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

---@type table<string, JavaSubCommands>
local subcommands = {
  test = {
    impl = function(args)
      if args[1] then
        local tests = require('my-java').find_tests()
        local set = {}
        for _, v in ipairs(tests) do
          set[v.name] = v
        end
        local test = set[args[1]]
        local test_args = {}
        table.move(args, 2, #args, 1, test_args)
        require('my-test').test({ test = test, test_args = test_args })
        return
      end

      require('my-test').test({ test_args = args })
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

local tab = nil

local function create_tab()
  if tab and vim.api.nvim_tabpage_is_valid(tab.tabnr) then
    vim.api.nvim_set_current_tabpage(tab.tabnr)
    return tab
  end

  vim.cmd('tabnew')
  local tabnr = vim.api.nvim_get_current_tabpage()
  -- TODO how to show this in the lualine?
  vim.api.nvim_tabpage_set_var(tabnr, 'tabname', 'test-diff')

  -- Opening a new tab without a file will create an empty buffer that I do not want. I don't know
  -- of a way to disable that behavior. So for now track its handle and delete it after opening
  -- other buffers. If I would delete it right away I would close the tab.
  local empty_buf = vim.api.nvim_win_get_buf(0)

  local right_buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_set_current_buf(right_buf)

  vim.cmd('vsplit')

  local left_buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_set_current_buf(left_buf)

  vim.api.nvim_buf_delete(empty_buf, { force = true })

  return {
    tabnr = tabnr,
    bufs = {
      left = left_buf,
      right = right_buf,
    },
  }
end

local function is_json(str)
  local ok, result = pcall(vim.fn.json_decode, str)
  return ok and result ~= nil
end

local function format_json(str)
  local result = vim.system({ 'jq' }, { text = true, stdin = str }):wait()
  return result.stdout
end

local function show_diff(assertion_lines)
  local junit_assertion_error_prefix = 'org.opentest4j.AssertionFailedError:'
  if not assertion_lines or not assertion_lines[1]:match(junit_assertion_error_prefix) then
    vim.notify(
      'Cursor must be on a line with a ' .. junit_assertion_error_prefix .. ' to generate a diff.',
      vim.log.levels.ERROR
    )
    return
  end

  local assertion_line = assertion_lines:gsub('\n', '')
  local expected_string = assertion_line:match('expected: <(.-)>')
  local actual_string = assertion_line:match('but was: <(.-)>')

  -- TODO get a sample of assertEquals of a lombok class with equals implementation
  if is_json(expected_string) and is_json(actual_string) then
    tab = create_tab()

    local formatted_expected = format_json(expected_string)
    local formatted_actual = format_json(actual_string)
    vim.api.nvim_buf_set_lines(tab.bufs.left, 0, -1, false, vim.split(formatted_expected, '\n'))
    vim.bo[tab.bufs.left].filetype = 'json'
    vim.api.nvim_buf_set_lines(tab.bufs.right, 0, -1, false, vim.split(formatted_actual, '\n'))
    vim.bo[tab.bufs.right].filetype = 'json'

    vim.cmd('windo diffthis')

    if not tab then
      vim.api.nvim_buf_set_name(tab.bufs.left, 'expected')
      vim.api.nvim_buf_set_name(tab.bufs.right, 'actual')

      for _, buf in pairs(tab.bufs) do
        vim.keymap.set('n', 'q', function()
          vim.cmd('tabclose')
          for _, buf_inner in pairs(tab.bufs) do
            vim.api.nvim_buf_delete(buf_inner, { force = true })
          end
        end, { buffer = buf })
      end
    end
  end
end

require('my-test').setup({
  finder = require('my-java').find_tests,
  runner = require('my-java').mvn_test,
  project_dir = require('my-java').find_mvn_root_dir(),
  keymaps = {
    {
      'n',
      'a',
      [[/org.opentest4j.AssertionFailedError:<CR>]],
      { desc = 'Search for failed assertions' },
    },
    {
      'n',
      'gd',
      function()
        local pre_selection_pos = vim.api.nvim_win_get_cursor(0)
        -- visually select line and search for the second closing '>' in "expected: <> but was: <>" string
        vim.cmd('normal! V')
        vim.fn.setreg('/', '>')
        vim.cmd('normal! n') -- starts search
        vim.cmd('normal! n')
        vim.cmd('normal! n')

        local selection =
          vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('v'), { type = vim.fn.mode() })
        local text = table.concat(selection, '\n')

        -- exit visual mode and re-position cursor
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true),
          'n',
          true
        )
        vim.api.nvim_win_set_cursor(0, pre_selection_pos)

        show_diff(text)
      end,
      { desc = 'Search for failed assertions' },
    },
    {
      'n',
      'f',
      [[/<<< FAILURE!\( --\)\@!<CR>]],
      { desc = 'Search for failed tests' },
    },
  },
})

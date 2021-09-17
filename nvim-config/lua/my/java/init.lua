local jdtls = require('jdtls')
local lsp_key_mappings = require('my.lsp.mappings')
local M = {}

local key_mappings = {
  {'n','<A-o>',[[<cmd>lua require('jdtls').organize_imports()<cr>]]},
  {'n','<leader>rv',[[<cmd>lua require('jdtls').extract_variable()<cr>]]},
  {'v','<leader>rv',[[<esc><cmd>lua require('jdtls').extract_variable(true)<cr>]]},
  {'n','<leader>rc',[[<cmd>lua require('jdtls').extract_constant()<cr>]]},
  {'v','<leader>rc',[[<esc><cmd>lua require('jdtls').extract_constant(true)<cr>]]},
  {'v','<leader>rm',[[<esc><cmd>lua require('jdtls').extract_method(true)<cr>]]},
}

local on_attach = function(client, bufnr)
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
end

function M.start_jdt()
  local root_markers = {'gradlew', '.git', 'pom.xml', 'mvnw'}
  local root_dir = require('jdtls.setup').find_root(root_markers)
  local home = os.getenv('HOME')
  local workspace_folder = home .. '/.local/share/eclipse/' .. vim.fn.fnamemodify(root_dir, ':p:h:t')

  -- nvim-cmp supports additional completion capabilities
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
  capabilities.workspace.configuration = true

  local extendedClientCapabilities = jdtls.extendedClientCapabilities;
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true;

  local config = {
    flags = {
        allow_incremental_sync = true,
    },
    cmd = {'java-lsp', workspace_folder},
    root_dir = root_dir,
    settings = {
      java = {
        signatureHelp = { enabled = true },
        contentProvider = { preferred = 'fernflower' },
        completion = {
          favoriteStaticMembers = {
            'org.hamcrest.MatcherAssert.assertThat',
            'org.hamcrest.Matchers.*',
            'org.hamcrest.CoreMatchers.*',
            'org.junit.jupiter.api.Assertions.*',
            'java.util.Objects.requireNonNull',
            'java.util.Objects.requireNonNullElse',
            'org.mockito.Mockito.*'
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
              path = '/usr/lib/jvm/java-11-openjdk-amd64/',
            },
          },
        },
      },
    },
    capabilities = capabilities,
    init_options = {
      extendedClientCapabilities = extendedClientCapabilities,
    },
    on_init = function(client, _)
        client.notify('workspace/didChangeConfiguration', { settings = config.settings })
    end,
    on_attach = on_attach,
  }

  jdtls.start_or_attach(config)
end

return M

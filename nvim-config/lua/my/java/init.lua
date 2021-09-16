local lsp = require 'vim.lsp'
local jdtls = require 'jdtls'
local M = {}

local function mk_config()
  local capabilities = lsp.protocol.make_client_capabilities()
  capabilities.workspace.configuration = true
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return {
    flags = {
      debounce_text_changes = 150,
      allow_incremental_sync = true,
    };
    handlers = {},
    capabilities = capabilities;
    on_init = on_init;
    on_attach = on_attach;
    on_exit = on_exit;
  }
end

local function jdtls_on_attach(client, bufnr)
  on_attach(client, bufnr, {
    server_side_fuzzy_completion = true,
    trigger_on_delete = false
  })
  local opts = { silent = true; }
  local nnoremap = function(lhs, rhs)
    api.nvim_buf_set_keymap(bufnr, 'n', lhs, rhs, opts)
  end
  -- TODO find a consistent mapping for Java, Go and maybe Lua
  nnoremap("<A-o>", "<Cmd>lua require'jdtls'.organize_imports()<CR>")

  nnoremap("crv", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>")
  nnoremap("crv", "<Cmd>lua require('jdtls').extract_variable()<CR>")
  nnoremap("crm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>")
  nnoremap("crc", "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>")
  nnoremap("crc", "<Cmd>lua require('jdtls').extract_constant()<CR>")
end

local function on_attach(client, bufnr, attach_opts)
  require('lsp_compl').attach(client, bufnr, attach_opts)
  api.nvim_buf_set_var(bufnr, "lsp_client_id", client.id)
  api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  api.nvim_buf_set_option(bufnr, "bufhidden", "hide")

  if client.resolved_capabilities.goto_definition then
    api.nvim_buf_set_option(bufnr, 'tagfunc', "v:lua.require'me.lsp.ext'.tagfunc")
  end
  local opts = { silent = true; }
  for _, mappings in pairs(key_mappings) do
    local capability, mode, lhs, rhs = unpack(mappings)
    if client.resolved_capabilities[capability] then
      api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
    end
  end
  -- TODO what about code formatting?
  -- TODO find consistent mappings accross languages
  -- TODO see if I can reuse some of these configurations for my LSP setup in general
  api.nvim_buf_set_keymap(bufnr, "n", "<space>", "<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
  api.nvim_buf_set_keymap(bufnr, "n", "crr", "<Cmd>lua vim.lsp.buf.rename(vim.fn.input('New Name: '))<CR>", opts)
  api.nvim_buf_set_keymap(bufnr, "n", "]w", "<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
  api.nvim_buf_set_keymap(bufnr, "n", "[w", "<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
  api.nvim_buf_set_keymap(bufnr, "i", "<c-n>", "<Cmd>lua require('lsp_compl').trigger_completion()<CR>", opts)
  vim.cmd('augroup lsp_aucmds')
  vim.cmd(string.format('au! * <buffer=%d>', bufnr))
  vim.cmd(string.format('au User LspDiagnosticsChanged <buffer=%d> redrawstatus!', bufnr))
  vim.cmd(string.format('au User LspMessageUpdate <buffer=%d> redrawstatus!', bufnr))
  if client.resolved_capabilities['document_highlight'] then
    vim.cmd(string.format('au CursorHold  <buffer=%d> lua vim.lsp.buf.document_highlight()', bufnr))
    vim.cmd(string.format('au CursorHoldI <buffer=%d> lua vim.lsp.buf.document_highlight()', bufnr))
    vim.cmd(string.format('au CursorMoved <buffer=%d> lua vim.lsp.buf.clear_references()', bufnr))
  end
  if vim.lsp.codelens and client.resolved_capabilities['code_lens'] then
    -- vim.cmd(string.format('au BufEnter,BufModifiedSet,InsertLeave <buffer=%d> lua vim.lsp.codelens.refresh()', bufnr))
    api.nvim_buf_set_keymap(bufnr, "n", "<leader>cr", "<Cmd>lua vim.lsp.codelens.refresh()<CR>", opts)
    api.nvim_buf_set_keymap(bufnr, "n", "<leader>ce", "<Cmd>lua vim.lsp.codelens.run()<CR>", opts)
  end
  vim.cmd('augroup end')
end

function M.start_jdt()
  local root_markers = {'gradlew', '.git', 'pom.xml', 'mvnw'}
  local root_dir = require('jdtls.setup').find_root(root_markers)
  local home = os.getenv('HOME')
  local workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
  local config = mk_config()
  config.flags.server_side_fuzzy_completion = true
  config.settings = {
    java = {
      signatureHelp = { enabled = true };
      contentProvider = { preferred = 'fernflower' };
      completion = {
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*"
        }
      };
      sources = {
        organizeImports = {
          starThreshold = 9999;
          staticStarThreshold = 9999;
        };
      };
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
        },
        useBlocks = true,
      };
      configuration = {
        runtimes = {
          {
            name = "JavaSE-11",
            path = "/usr/lib/jvm/java-11-openjdk-amd64/",
          },
        }
      };
    };
  }
  config.cmd = {'java-lsp', workspace_folder}
  config.on_attach = jdtls_on_attach
  -- mute; having progress reports is enough
  -- config.handlers['language/status'] = function() end
  jdtls.start_or_attach(config)
end

return M

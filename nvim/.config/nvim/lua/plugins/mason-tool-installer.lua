return {
  -- TODO why does this being lazy influence the loading of lsp which is what is actually slow?
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  lazy = true,
  cmd = {
    'MasonToolsInstall',
    'MasonToolsInstallSync',
    'MasonToolsUpdate',
    'MasonToolsUpdateSync',
    'MasonToolsClean',
  },
  opts = {
    -- LSPs are installed by mason-lspconfig.nvim
    -- see ../plugins/lsp/init.lua
    ensure_installed = {
      'codespell',
      'delve',
      'golangci-lint',
      -- keep in sync with version used in ~/code/dhis2/core/dhis-2/pom.xml
      { 'google-java-format', version = 'v1.24.0' },
      'shellcheck',
      'sqlfmt',
      'stylua',
      -- 'luacheck', -- TODO fails to install
    },
    auto_update = false,
    run_on_start = false,
    -- start_delay = 3000, -- 3 second delay
    -- debounce_hours = 5, -- at least 5 hours between attempts to install/update
  },
}

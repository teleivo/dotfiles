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
    -- Keep LSPs in sync with ../plugins/lsp/init.lua or refactor and make the lsp list reusable.
    -- See https://github.com/williamboman/mason-lspconfig.nvim/issues/12 for why I am using this
    -- plugin to install them and keep them up to date.
    -- Using LSP names I use in mason-lspconfig. I am not sure if I am doing this totally correct as
    -- I suspect this plugin should then depend on mason-lspconfig. I had some lazy loading issues
    -- so I don't want to touch this for now.
    -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim?tab=readme-ov-file#configuration
    -- LSP names and repos can also be found in
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
    ensure_installed = {
      'codespell',
      'delve',
      { 'golangci-lint', version = 'v1.64.8' },
      -- keep in sync with version used in ~/code/dhis2/core/dhis-2/pom.xml
      { 'google-java-format', version = 'v1.24.0' },
      'shellcheck',
      'sqlfmt',
      'stylua',
      'gopls', -- https://github.com/golang/tools/tree/master/gopls
      'yamlls', -- https://github.com/redhat-developer/yaml-language-server
      'bashls', -- https://github.com/bash-lsp/bash-language-server
      'denols', -- https://github.com/denoland/deno
      'jsonls', -- extracted from https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server
      'lua_ls', -- https://github.com/LuaLS/lua-language-server
      'marksman', -- https://github.com/artempyanykh/marksman
      -- 'luacheck', -- TODO fails to install
    },
    auto_update = false, -- update manually so I don't have to deal with any bugs in new versions when I don't have time
    run_on_start = false,
    -- start_delay = 3000, -- 3 second delay
    -- debounce_hours = 5, -- at least 5 hours between attempts to install/update
  },
}

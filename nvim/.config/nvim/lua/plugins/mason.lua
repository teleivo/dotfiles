return {
	-- Mason package manager
	{
		"mason-org/mason.nvim",
		version = "v2.*",
		cmd = "Mason", -- Lazy load mason - only needed for :Mason command
		config = function()
			require("mason").setup()
		end,
		build = ":MasonUpdate",
	},

	-- Declarative tool installation
	{
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
			-- LSP names and repos can also be found in
			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
			ensure_installed = {
				{ 'codespell', version = '2.4.1' },
				'delve', -- binary release, no version pinning available
				{ 'golangci-lint', version = 'v1.64.8' },
				-- keep in sync with version used in ~/code/dhis2/core/dhis-2/pom.xml
				{ 'google-java-format', version = 'v1.24.0' },
				'shellcheck', -- binary release, no version pinning available
				'sqlfmt', -- binary release, no version pinning available
				-- TODO setup
				-- 'postgrestools', -- https://github.com/supabase-community/postgres-language-server
				{ 'stylua', version = 'v2.2.0' },
				'gopls', -- https://github.com/golang/tools/tree/master/gopls
				{ 'yamlls', version = '1.17.0' }, -- https://github.com/redhat-developer/yaml-language-server
				{ 'bashls', version = '5.4.3' }, -- https://github.com/bash-lsp/bash-language-server
				'denols', -- https://github.com/denoland/deno
				{ 'jsonls', version = '4.10.0' }, -- extracted from https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server
				'lua_ls', -- https://github.com/LuaLS/lua-language-server
				'ruff', -- https://github.com/astral-sh/ruff
				{ 'marksman', version = '2024-12-18' }, -- https://github.com/artempyanykh/marksman
				-- 'luacheck', -- TODO fails to install
			},
			auto_update = false, -- update manually so I don't have to deal with any bugs in new versions when I don't have time
			run_on_start = false,
			-- start_delay = 3000, -- 3 second delay
			-- debounce_hours = 5, -- at least 5 hours between attempts to install/update
		},
	},
}
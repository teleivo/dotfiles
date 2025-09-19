local servers = {
	-- jdtls is managed by nvim-jdtls and therefore not defined here
	-- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jdtls
	bashls = {},
	denols = {},
	jsonls = {},
	lua_ls = {
		Lua = {
			workspace = {
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
			format = {
				enable = false,
			},
			completion = {
				autorequire = true,
				callSnippet = "Replace",
				keywordSnippet = "Replace",
				postfix = ".",
				showParams = false,
			},
			hint = {
				enable = true,
				await = true,
			},
		},
	},
	ruff = {
		configurationPreference = "filesystemFirst",
	},
	marksman = {},
	-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
	gopls = {
		gopls = {
			gofumpt = true,
			usePlaceholders = true,
			linksInHover = "gopls",
			hints = {
				compositeLiteralFields = true,
				constantValues = true,
			},
			-- verboseOutput = true, -- uncomment for debugging
			-- available analyzers https://github.com/golang/tools/blob/master/gopls/doc/analyzers.md
			-- analyses = {
			-- },
			staticcheck = true,
			-- report vulnerabilities that affect packages directly and indirectly used by the analyzed main module
			vulncheck = "Imports",
		},
	},
	yamlls = {
		yaml = {
			format = {
				enable = true,
				bracketSpacing = false,
			},
			editor = {
				formatOnType = true,
			},
			schemas = {
				["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
				["https://json.schemastore.org/dependabot-2.0.json"] = "/.github/dependabot.yml",
				["https://json.schemastore.org/golangci-lint.json"] = { ".golangci.yml", ".golangci.yaml" },
				["https://goreleaser.com/static/schema.json"] = ".goreleaser.yml",
				["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.yml",
				["https://raw.githubusercontent.com/ansible-community/schemas/main/f/ansible-tasks.json"] = "/playbooks/**/tasks/*.yml",
				["https://raw.githubusercontent.com/ansible-community/schemas/main/f/ansible-playbook.json"] = "/playbooks/*.yml",
			},
		},
	},
}

-- Modern LspAttach autocmd instead of per-server on_attach
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my_lsp_attach', { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local bufnr = args.buf

		-- enable inlay hints if supported
		-- for example https://github.com/golang/tools/blob/master/gopls/doc/settings.md#inlayhint
		if client.server_capabilities.inlayHintProvider then
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		end

		-- highlight currently selected symbol
		if client.server_capabilities.documentHighlightProvider then
			local group = vim.api.nvim_create_augroup("my_lsp_" .. bufnr, { clear = true })
			vim.api.nvim_create_autocmd("CursorHold", {
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.document_highlight()
				end,
				group = group,
			})
			vim.api.nvim_create_autocmd("CursorMoved", {
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.clear_references()
				end,
				group = group,
			})
		end

		for _, mappings in pairs(require("my-lsp").keymaps) do
			local mode, lhs, rhs, opts = unpack(mappings)
			vim.keymap.set(mode, lhs, rhs, vim.tbl_deep_extend("error", opts, { buffer = bufnr, silent = true }))
		end
	end,
})

-- Setup LSP servers using native vim.lsp.config
local function setup_lsp_servers()
	local ok, blink = pcall(require, "blink.cmp")
	if not ok then
		vim.notify("blink.cmp not available, skipping LSP setup", vim.log.levels.WARN)
		return
	end

	local capabilities = blink.get_lsp_capabilities()
	local lsp_configs = require("plugins.lsp.configs").configs

	for server_name, settings in pairs(servers) do
		local config = lsp_configs[server_name]
		if config then
			-- Configure the server using the new 0.11+ API
			vim.lsp.config(server_name, vim.tbl_deep_extend("force", config, {
				capabilities = capabilities,
				settings = settings,
			}))

			-- Enable the server to actually start it
			vim.lsp.enable(server_name)

			vim.notify("Configured and enabled LSP server: " .. server_name, vim.log.levels.INFO)
		else
			vim.notify("No config found for LSP server: " .. server_name, vim.log.levels.WARN)
		end
	end
end

return {
	{
		"mason-org/mason.nvim",
		version = "v1.*",
		cmd = "Mason",
		lazy = false, -- Load mason immediately so LSP servers can be configured
		config = function()
			require("mason").setup()
			-- Setup LSP servers immediately - no artificial delays needed
			setup_lsp_servers()
		end,
		build = ":MasonUpdate",
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
}

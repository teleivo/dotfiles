return {
	cmd = { vim.fn.stdpath("data") .. "/mason/bin/lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		".stylua.toml",
		"stylua.toml",
		"selene.toml",
		"selene.yml",
		".git",
	},
	single_file_support = true,
	settings = {
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
}
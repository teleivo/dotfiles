-- extracted from https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server
return {
	cmd = { vim.fn.stdpath("data") .. "/mason/bin/vscode-json-language-server", "--stdio" },
	filetypes = { "json", "jsonc" },
	root_markers = { ".git" },
	single_file_support = true,
	init_options = {
		provideFormatter = true,
	},
}
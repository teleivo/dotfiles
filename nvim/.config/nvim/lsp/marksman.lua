-- https://github.com/artempyanykh/marksman
return {
	cmd = { vim.fn.stdpath("data") .. "/mason/bin/marksman", "server" },
	filetypes = { "markdown", "markdown.mdx" },
	root_markers = { ".marksman.toml", ".git" },
	single_file_support = true,
}
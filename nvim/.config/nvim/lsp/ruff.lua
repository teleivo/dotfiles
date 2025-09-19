-- https://github.com/astral-sh/ruff
return {
	cmd = { vim.fn.stdpath("data") .. "/mason/bin/ruff", "server" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"ruff.toml",
		".ruff.toml",
		".git",
	},
	single_file_support = true,
	init_options = {
		settings = {
			configurationPreference = "filesystemFirst",
		},
	},
	settings = {
		configurationPreference = "filesystemFirst",
	},
}
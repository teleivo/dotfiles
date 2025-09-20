-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
return {
	cmd = { vim.fn.stdpath("data") .. "/mason/bin/gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.work", "go.mod", ".git" },
	single_file_support = true,
	settings = {
		gopls = {
			gofumpt = true,
			usePlaceholders = true,
			linksInHover = true,
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
}
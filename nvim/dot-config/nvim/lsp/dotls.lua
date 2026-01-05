-- https://github.com/teleivo/dot
return {
	cmd = { "dotx", "lsp", "-tracefile", vim.fn.expand("~/code/dot/dotls.log") },
	filetypes = { "dot" },
	single_file_support = true,
	capabilities = {
		general = {
			positionEncodings = { "utf-8" },
		},
	},
}

-- https://github.com/denoland/deno
return {
	cmd = { vim.fn.stdpath("data") .. "/mason/bin/deno", "lsp" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	root_markers = { "deno.json", "deno.jsonc", ".git" },
	single_file_support = true,
	init_options = {
		enable = true,
		lint = true,
		unstable = true,
	},
}
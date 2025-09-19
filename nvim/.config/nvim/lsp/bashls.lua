-- https://github.com/bash-lsp/bash-language-server
return {
	cmd = { vim.fn.stdpath("data") .. "/mason/bin/bash-language-server", "start" },
	filetypes = { "sh" },
	root_markers = { ".git" },
	single_file_support = true,
}
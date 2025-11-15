-- Lua development for Neovim
return {
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
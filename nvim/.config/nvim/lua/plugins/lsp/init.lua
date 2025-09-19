-- LSP configuration is now handled natively in init.lua using vim.lsp.config()
-- This file only manages mason.nvim for tool installation

return {
	{
		"mason-org/mason.nvim",
		version = "v1.*",
		cmd = "Mason", -- Lazy load mason - only needed for :Mason command
		config = function()
			require("mason").setup()
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
-- load snippets from runtimepath, eg. friendly-snippets.
require('luasnip.loaders.from_vscode').lazy_load()

local types = require("luasnip.util.types")

-- TODO remove if not useful ;)
require('luasnip').config.setup({
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = {{'●', 'SpecialKey'}}
			}
		},
		[types.insertNode] = {
			active = {
				virt_text = {{'●', 'Function'}}
			}
		}
	},
})

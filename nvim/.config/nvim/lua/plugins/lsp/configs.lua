-- LSP Server Configurations
--
-- Based on configurations from nvim-lspconfig
-- Source: https://github.com/neovim/nvim-lspconfig
-- License: Apache License 2.0
--
-- Copyright Neovim
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local M = {}

-- Helper functions no longer needed with native vim.lsp.config() and root_markers

M.configs = {
	bashls = {
		cmd = { "bash-language-server", "start" },
		filetypes = { "sh" },
		root_markers = { ".git" },
		single_file_support = true,
	},

	denols = {
		cmd = { "deno", "lsp" },
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
	},

	jsonls = {
		cmd = { "vscode-json-language-server", "--stdio" },
		filetypes = { "json", "jsonc" },
		root_markers = { ".git" },
		single_file_support = true,
		init_options = {
			provideFormatter = true,
		},
	},

	lua_ls = {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		root_markers = {
			".luarc.json",
			".luarc.jsonc",
			".luacheckrc",
			".stylua.toml",
			"stylua.toml",
			"selene.toml",
			"selene.yml",
			".git",
		},
		single_file_support = true,
	},

	ruff = {
		cmd = { "ruff", "server" },
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
	},

	marksman = {
		cmd = { "marksman", "server" },
		filetypes = { "markdown", "markdown.mdx" },
		root_markers = { ".marksman.toml", ".git" },
		single_file_support = true,
	},

	gopls = {
		cmd = { "gopls" },
		filetypes = { "go", "gomod", "gowork", "gotmpl" },
		root_markers = { "go.work", "go.mod", ".git" },
		single_file_support = true,
	},

	yamlls = {
		cmd = { "yaml-language-server", "--stdio" },
		filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
		root_markers = { ".git" },
		single_file_support = true,
		settings = {
			redhat = { telemetry = { enabled = false } },
		},
	},
}

return M

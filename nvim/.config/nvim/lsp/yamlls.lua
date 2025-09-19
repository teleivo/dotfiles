-- https://github.com/redhat-developer/yaml-language-server
return {
	cmd = { vim.fn.stdpath("data") .. "/mason/bin/yaml-language-server", "--stdio" },
	filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
	root_markers = { ".git" },
	single_file_support = true,
	settings = {
		redhat = { telemetry = { enabled = false } },
		yaml = {
			format = {
				enable = true,
				bracketSpacing = false,
			},
			editor = {
				formatOnType = true,
			},
			schemas = {
				["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
				["https://json.schemastore.org/dependabot-2.0.json"] = "/.github/dependabot.yml",
				["https://json.schemastore.org/golangci-lint.json"] = { ".golangci.yml", ".golangci.yaml" },
				["https://goreleaser.com/static/schema.json"] = ".goreleaser.yml",
				["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.yml",
				["https://raw.githubusercontent.com/ansible-community/schemas/main/f/ansible-tasks.json"] = "/playbooks/**/tasks/*.yml",
				["https://raw.githubusercontent.com/ansible-community/schemas/main/f/ansible-playbook.json"] = "/playbooks/*.yml",
			},
		},
	},
}
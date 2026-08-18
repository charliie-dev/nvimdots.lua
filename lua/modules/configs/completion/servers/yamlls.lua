-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/yamlls.lua
return {
	filetypes = { "yaml", "yaml.docker-compose", "yaml.github", "yaml.gitlab", "yaml.helm-values" },
	on_init = function(client)
		if client.server_capabilities then
			client.server_capabilities.documentFormattingProvider = nil
			client.server_capabilities.documentRangeFormattingProvider = nil
		end
	end,
	settings = {
		-- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
		redhat = { telemetry = { enabled = false } },
		yaml = {
			validate = true,
			completion = true,
			format = { enable = false },
			hover = true,
			schemaStore = {
				-- You must disable built-in schemaStore support if you want to use
				-- SchemaStore.nvim and its advanced options like `ignore`.
				enable = false,
				-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
				url = "",
			},
			schemas = require("schemastore").yaml.schemas({
				ignore = { "Traefik v2" },
				extra = {
					{
						name = "azure-pipelines",
						description = "azure-pipelines YAML schema",
						fileMatch = { "azure-pipelines.{yml,yaml}" },
						url = "https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json",
					},
					{
						name = "Traefik v3",
						description = "Traefik v3 static configuration",
						fileMatch = { "traefik.yml", "traefik.yaml" },
						url = "https://www.schemastore.org/traefik-v3.json",
					},
				},
				replace = {
					["gh-dash"] = {
						name = "gh-dash",
						description = "Configuration for the gh-dash GitHub CLI dashboard",
						fileMatch = {
							".gh-dash.yml",
							".gh-dash.yaml",
							"**/gh-dash/config.yml",
							"**/gh-dash/config.yaml",
						},
						url = "https://gh-dash.dev/schema.json",
					},
				},
			}),
			-- trace = { server = "verbose" },
		},
	},
}

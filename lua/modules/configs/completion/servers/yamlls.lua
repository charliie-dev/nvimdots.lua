-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/yamlls.lua
return {
	single_file_support = true,
	debounce_text_changes = 150,
	settings = {
		-- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
		redhat = { telemetry = { enabled = false } },
		yaml = {
			validate = true,
			completion = true,
			format = { enable = false },
			hover = true,
			schemaDownload = { enable = true },
			schemaStore = {
				-- You must disable built-in schemaStore support if you want to use
				-- SchemaStore.nvim and its advanced options like `ignore`.
				enable = false,
				-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
				url = "",
			},
			schemas = require("schemastore").yaml.schemas({
				extra = {
					{
						name = "azure-pipelines",
						description = "azure-pipelines YAML schema",
						fileMatch = { "azure-pipelines.{yml,yaml}" },
						url = "https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json",
					},
					{
						name = "gh-dash config",
						description = "gh-dash config YAML schema",
						fileMatch = "*/gh-dash/config.yml",
						url = "https://dlvdhr.github.io/gh-dash/configuration/gh-dash/schema.json",
					},
					{
						name = "Traefik v3",
						description = "Traefik v3 static configuration",
						fileMatch = { "traefik.yml", "traefik.yaml" },
						url = "https://www.schemastore.org/traefik-v3.json",
					},
				},
				-- Override built-in Traefik v2 with v3
				replace = {
					["Traefik v2"] = {
						name = "Traefik v3",
						description = "Traefik v3 static configuration",
						fileMatch = { "traefik.yml", "traefik.yaml" },
						url = "https://www.schemastore.org/traefik-v3.json",
					},
				},
			}),
			-- trace = { server = "debug" },
		},
	},
}

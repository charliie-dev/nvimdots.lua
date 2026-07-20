-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/yamlls.lua
-- Our own Traefik v3 schema URL, referenced by the extra below and by the
-- traefik-claim cleanup after it.
local traefik_v3_url = "https://www.schemastore.org/traefik-v3.json"
local schemas = require("schemastore").yaml.schemas({
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
			fileMatch = "*/gh-dash/config.{yml,yaml}",
			url = "https://www.gh-dash.dev/schema.json",
		},
		-- The catalog's own "Traefik v3" entry carries no fileMatch, so this
		-- extra is what actually claims the static-config files for v3.
		{
			name = "Traefik v3",
			description = "Traefik v3 static configuration",
			fileMatch = { "traefik.{yml,yaml}" },
			url = traefik_v3_url,
		},
	},
})
-- traefik.{yml,yaml} belong to our Traefik v3 extra alone: strip traefik globs
-- from every OTHER schema (the catalog's v2 entry claims the same files).
-- Matched on the file pattern, not v2's name/URL, so a catalog rename can't let
-- v2 re-claim them. Keys snapshotted so `schemas` isn't mutated mid-pairs.
for _, url in ipairs(vim.tbl_keys(schemas)) do
	local fileMatch = schemas[url]
	if url ~= traefik_v3_url then
		if type(fileMatch) == "string" then
			if fileMatch:find("traefik", 1, true) then
				schemas[url] = nil
			end
		elseif type(fileMatch) == "table" then
			local kept = {}
			for _, glob in ipairs(fileMatch) do
				if not (type(glob) == "string" and glob:find("traefik", 1, true)) then
					kept[#kept + 1] = glob
				end
			end
			schemas[url] = #kept > 0 and kept or nil
		end
	end
end

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
			schemas = schemas,
			-- trace = { server = "debug" },
		},
	},
}

-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/yamlls.lua

-- Kubernetes manifests have no fixed file name, so SchemaStore cannot match them. Once a buffer has
-- top-level `apiVersion` and `kind`, and no other schema (e.g. SchemaStore's kustomization.yaml)
-- already claims it, map it to yaml-language-server's built-in `kubernetes` schema.
local function is_manifest(bufnr)
	local api_version, kind = false, false
	for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
		api_version = api_version or line:find("^apiVersion:%s*%S") ~= nil
		kind = kind or line:find("^kind:%s*%S") ~= nil
		if api_version and kind then
			return true
		end
	end
	return false
end

local function map_kubernetes_schema(client, bufnr)
	if client:is_stopped() or not vim.api.nvim_buf_is_valid(bufnr) or not is_manifest(bufnr) then
		return
	end
	local uri = vim.uri_from_bufnr(bufnr)
	local schemas = client.settings.yaml.schemas
	if vim.tbl_contains(schemas.kubernetes or {}, uri) then
		return
	end
	client:request("yaml/get/jsonSchema", uri, function(err, result)
		if err or (result and #result > 0) or vim.tbl_contains(schemas.kubernetes or {}, uri) then
			return
		end
		schemas.kubernetes = schemas.kubernetes or {}
		table.insert(schemas.kubernetes, uri)
		client:notify("workspace/didChangeConfiguration", { settings = client.settings })
	end, bufnr)
end

return {
	filetypes = { "yaml", "yaml.docker-compose", "yaml.github", "yaml.gitlab", "yaml.helm-values" },
	on_attach = function(client, bufnr)
		map_kubernetes_schema(client, bufnr)
		-- Re-check after edits so a new manifest picks up the schema without reopening it
		vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost" }, {
			group = vim.api.nvim_create_augroup("YamllsKubernetesSchema" .. bufnr, { clear = true }),
			buffer = bufnr,
			callback = function()
				map_kubernetes_schema(client, bufnr)
			end,
		})
	end,
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

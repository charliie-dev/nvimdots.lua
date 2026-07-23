-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/yamlls.lua
-- Our own Traefik v3 schema URL and literal claimed files, referenced by the
-- extra below and by the traefik-claim cleanup after it.
local traefik_v3_url = "https://www.schemastore.org/traefik-v3.json"
local traefik_v3_files = { "traefik.yml", "traefik.yaml" }
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
			-- The DOCUMENTED canonical form (docs + astro site config use the
			-- bare host; the www alias is just today's hosting redirect target).
			url = "https://gh-dash.dev/schema.json",
		},
		-- The catalog's own "Traefik v3" entry carries no fileMatch, so this
		-- extra is what actually claims the static-config files for v3.
		{
			name = "Traefik v3",
			description = "Traefik v3 static configuration",
			fileMatch = traefik_v3_files,
			url = traefik_v3_url,
		},
	},
})

-- The files our v3 extra claims — LITERALS by contract (asserted), so the
-- prune below is exact-basename matching, no glob engine. Derived from the
-- extra itself (no mirror of catalog naming); matched on the file pattern,
-- not v2's name/URL, so a catalog rename can't let v2 re-claim them
-- (schemastore's replace/ignore match by name and can't give that).
local claimed = {}
for _, file in ipairs(traefik_v3_files) do
	-- A future edit that sneaks glob magic back in must fail loudly: the
	-- literal contract is what licenses basename equality as the whole test.
	assert(not file:find("[%*%?%[{]"), "traefik_v3_files must be literal filenames: " .. file)
	claimed[file] = true
end
-- Stems ("traefik"), for the visibility WARN below — derived, not mirrored.
local claimed_stems = {}
for file in pairs(claimed) do
	local stem = file:match("^[^.]+")
	assert(stem and stem ~= "", "claimed file yields no stem: " .. file)
	claimed_stems[stem:lower()] = true
end

---Basename of a glob, both slash kinds split uniformly on EVERY platform —
---deliberately NOT vim.fs.basename: it splits only "/" as a separator and
---normalizes backslashes only on Windows (probe-verified here:
---vim.fs.basename("a\\b.yml") == "a\\b.yml" on Darwin), which would silently
---change prune verdicts for backslash-carrying globs on mac/linux (schema
---selection is correctness). A separator-terminated glob ("dir/") falls back
---to the whole string.
---@param glob string
---@return string
local function glob_basename(glob)
	return glob:match("([^/\\]+)$") or glob
end

---A glob conflicts exactly when its basename IS a claimed literal: v2's
---`traefik.yml`/`traefik.yaml` and `**/`-prefixed forms do; traefik-NAMED
---globs (.traefik.yml, traefik-dynamic.*) do not and keep their schemas.
---Non-string catalog drift keeps its silent degrade (kept, never thrown on).
---@param glob any
---@return boolean
local function check_glob(glob)
	if type(glob) ~= "string" then
		return false
	end
	local base = glob_basename(glob)
	return claimed[base] == true
end

-- Strip exactly the claimed files from every OTHER schema (the catalog's v2
-- entry). Keys snapshotted so `schemas` isn't mutated mid-pairs. Brace globs
-- whose basename mentions a claimed stem are past this literal matcher:
-- KEPT (fail-open) and WARNED for review — see the disposition note below.
local kept_unjudged = {}
local function note_if_unjudged(glob)
	if type(glob) == "string" and glob:find("[{}]") then
		-- De-brace the basename before the stem test: a brace can split the
		-- stem ("trae{fik,x}.yml"), which a contiguous find would miss
		-- (round-1 gate finding — the sentinel must see through alternation).
		local base = glob_basename(glob):lower():gsub("[{},]", "")
		for stem in pairs(claimed_stems) do
			if base:find(stem, 1, true) then
				kept_unjudged[#kept_unjudged + 1] = glob
				return
			end
		end
	end
end
for _, url in ipairs(vim.tbl_keys(schemas)) do
	local fileMatch = schemas[url]
	if url ~= traefik_v3_url then
		if type(fileMatch) == "string" then
			if check_glob(fileMatch) then
				schemas[url] = nil
			else
				note_if_unjudged(fileMatch)
			end
		elseif type(fileMatch) == "table" then
			local kept = {}
			for _, glob in ipairs(fileMatch) do
				if not check_glob(glob) then
					kept[#kept + 1] = glob
					note_if_unjudged(glob)
				end
			end
			schemas[url] = #kept > 0 and kept or nil
		end
	end
end
-- Visibility sentinel (disposition REVISED from the round-3 engine: it
-- DROPPED these fail-closed; we KEEP them and warn). Rationale: the trigger
-- set is empty in the entire installed catalog (braces exist only in our own
-- extras), a wrong drop silently loses a wanted schema, while a wrong keep
-- surfaces as yaml-ls's own multi-schema conflict PLUS this WARN. Scheduled:
-- this module loads on the first-file-open tick, possibly before the notifier.
if #kept_unjudged > 0 then
	table.sort(kept_unjudged)
	vim.schedule(function()
		vim.notify(
			"yamlls schema prune: kept brace fileMatch globs that mention a claimed\n"
				.. "file's stem but are past the literal matcher — review for a v2/v3\n"
				.. "schema conflict:\n  • "
				.. table.concat(kept_unjudged, "\n  • "),
			vim.log.levels.WARN,
			{ title = "completion.servers.yamlls" }
		)
	end)
end

return {
	single_file_support = true,
	debounce_text_changes = 150,
	-- Core attaches by EXACT filetype match (no dot splitting), so the dotted
	-- workflow filetype from ftdetect/github.lua must be claimed explicitly.
	-- Upstream's list (nvim-lspconfig lsp/yamlls.lua) plus our yaml.github;
	-- accepted trade-off: a dotted variant upstream adds later must be
	-- mirrored here (the same rot class as any repo filetypes override).
	filetypes = { "yaml", "yaml.docker-compose", "yaml.github", "yaml.gitlab", "yaml.helm-values" },
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

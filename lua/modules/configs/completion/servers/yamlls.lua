-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/yamlls.lua
-- Our own Traefik v3 schema URL and claimed files, referenced by the extra
-- below and by the traefik-claim cleanup after it.
local traefik_v3_url = "https://www.schemastore.org/traefik-v3.json"
local traefik_v3_files = { "traefik.{yml,yaml}" }
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

---Bounded worklist expansion of `{a,b,...}` alternations: multi-group globs
---flatten to their full product, capped so a pathological upstream glob can't
---allocate a Cartesian blow-up on the startup path. `truncated` (cap hit)
---means the matcher could not judge the glob; a brace-less glob expands to
---itself. (The claimed-file check below judges leaves DURING expansion and
---does not use this list form — this stays for building `claimed` itself.)
local BRACE_EXPANSION_CAP = 64
---@param glob string
---@return string[] expanded
---@return boolean truncated
local function expand_braces(glob)
	local work, out, truncated = { glob }, {}, false
	while #work > 0 and not truncated do
		local current = table.remove(work)
		local head, alts, tail = current:match("^(.-){([^{}]+)}(.-)$")
		if not head then
			out[#out + 1] = current
		else
			for alt in (alts .. ","):gmatch("([^,]*),") do
				if #work + #out >= BRACE_EXPANSION_CAP then
					truncated = true
					break
				end
				work[#work + 1] = head .. alt .. tail
			end
		end
	end
	return out, truncated
end

-- The files our v3 extra claims, expanded: the ONLY globs other schemas may
-- not keep. Derived from the extra itself (no mirror of catalog naming).
local claimed = {}
for _, glob in ipairs(traefik_v3_files) do
	for _, expanded in ipairs(expand_braces(glob)) do
		claimed[expanded] = true
	end
end
-- Stems of the claimed files ("traefik"), derived from our own extra — the
-- sentinel gate below never mirrors catalog naming. A glob beyond the
-- matcher that never mentions a stem cannot literally claim a stemmed file
-- under exact-basename matching (wildcards were never in scope).
local claimed_stems = {}
for expanded in pairs(claimed) do
	local stem = expanded:match("^[^.]+")
	if stem and stem ~= "" then
		claimed_stems[stem:lower()] = true
	end
end
---@param glob string
---@return boolean
local function mentions_claimed_stem(glob)
	local lower = glob:lower()
	for stem in pairs(claimed_stems) do
		if lower:find(stem, 1, true) then
			return true
		end
	end
	return false
end

---A glob conflicts only when its basename expands to a claimed file: v2's
---`traefik.yml`/`traefik.yaml` (and `**/`-prefixed forms) do; merely
---traefik-NAMED globs (.traefik.yml plugin manifests, traefik-dynamic.*)
---do not and keep their schemas. Leaves are judged DURING the bounded
---expansion, so a claimed file short-circuits `claims` even when the full
---product would blow the cap. The second result flags a glob BEYOND the
---matcher (cap hit before a claim was found, or unbalanced braces): the
---caller must not trust the false and decides fail-closed.
---@param glob any
---@return boolean claims
---@return boolean beyond
local function claims_same_files(glob)
	if type(glob) ~= "string" then
		return false, false
	end
	local base = glob:match("([^/\\]+)$") or glob
	local work, seen, beyond = { base }, 0, false
	while #work > 0 do
		local current = table.remove(work)
		local head, alts, tail = current:match("^(.-){([^{}]+)}(.-)$")
		if not head then
			if claimed[current] then
				return true, beyond
			end
			if current:find("{", 1, true) or current:find("}", 1, true) then
				beyond = true
			end
		else
			for alt in (alts .. ","):gmatch("([^,]*),") do
				local candidate = head .. alt .. tail
				if candidate:find("{", 1, true) then
					seen = seen + 1
					if seen > BRACE_EXPANSION_CAP then
						return false, true
					end
					work[#work + 1] = candidate
				elseif claimed[candidate] then
					-- Judged immediately: no cap gate may starve a claim check.
					return true, beyond
				else
					seen = seen + 1
					if seen > BRACE_EXPANSION_CAP then
						return false, true
					end
					if candidate:find("}", 1, true) then
						beyond = true
					end
				end
			end
		end
	end
	return false, beyond
end

-- traefik.{yml,yaml} belong to our Traefik v3 extra alone: strip exactly those
-- claims from every OTHER schema (the catalog's v2 entry). Matched on the file
-- pattern, not v2's name/URL, so a catalog rename can't let v2 re-claim them.
-- Keys snapshotted so `schemas` isn't mutated mid-pairs. Globs the bounded
-- matcher could not judge (and that mention a claimed stem) are collected for
-- the sentinel below instead of being silently trusted as non-conflicting.
local dropped_unjudgeable = {}
local function check_glob(glob)
	local claims, beyond = claims_same_files(glob)
	if claims then
		return true
	end
	-- FAIL CLOSED: a glob the matcher cannot judge that mentions a claimed
	-- stem may still cover the claimed files — drop it (the same conflict-
	-- removal-wins trade-off as a mixed multi-group glob) and warn below so
	-- over-pruning stays reviewable.
	if beyond and mentions_claimed_stem(glob) then
		dropped_unjudgeable[#dropped_unjudgeable + 1] = glob
		return true
	end
	return false
end
for _, url in ipairs(vim.tbl_keys(schemas)) do
	local fileMatch = schemas[url]
	if url ~= traefik_v3_url then
		if type(fileMatch) == "string" then
			if check_glob(fileMatch) then
				schemas[url] = nil
			end
		elseif type(fileMatch) == "table" then
			local kept = {}
			for _, glob in ipairs(fileMatch) do
				if not check_glob(glob) then
					kept[#kept + 1] = glob
				end
			end
			schemas[url] = #kept > 0 and kept or nil
		end
	end
end
-- Capability sentinel: upstream shapes past the matcher's limit failed
-- CLOSED (dropped above) so the v2/v3 conflict cannot survive — say so, and
-- name the globs so over-pruning stays reviewable. Scheduled: this module
-- loads on the first-file-open tick, possibly before the notifier.
if #dropped_unjudgeable > 0 then
	table.sort(dropped_unjudgeable)
	vim.schedule(function()
		vim.notify(
			"yamlls schema prune: dropped fileMatch globs the bounded brace matcher\n"
				.. "could not judge (they mention a claimed file's stem) — review if a\n"
				.. "wanted schema lost files:\n  • "
				.. table.concat(dropped_unjudgeable, "\n  • "),
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
	-- mirrored here (same rot class as any repo filetypes override — tracked
	-- by eager_ft_override_modules' anti-rot hook).
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

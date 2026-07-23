-- One-off migration guards for settings keys removed from the declarative
-- surface: core/settings.lua calls M.check(merged) once per startup after the
-- user merge. The imperative classification/notify logic lives here so
-- settings.lua stays a pure declarative source of truth; add future removed-key
-- guards as further branches in M.check (same pattern), not in settings.lua.
local M = {}

---Warn about residue of settings keys the refactors removed.
---@param merged table @The post-merge settings table (read, never written).
function M.check(merged)
	-- Migration guard: the discovery-first refactor removed this key; a stale
	-- user/settings.lua would merge it in and feed nothing — its servers would
	-- vanish without a word.
	if merged.external_lsp_deps ~= nil then
		-- The removed setting was a MAP of server name -> executable name, but a
		-- stale override can survive in any shape: classify before advising so the
		-- guidance never presents numeric indices as keys, never drops entries a
		-- half-migrated LIST residue still carries, and always names the final
		-- step (deleting the dead key). Neither group suppresses the other.
		local string_keys, list_items = {}, {}
		if type(merged.external_lsp_deps) == "table" then
			for k, v in pairs(merged.external_lsp_deps) do
				if type(k) == "string" then
					string_keys[#string_keys + 1] = k
				elseif type(k) == "number" and type(v) == "string" then
					list_items[#list_items + 1] = v
				end
			end
			table.sort(string_keys)
			table.sort(list_items)
		end
		local guidance
		if #string_keys > 0 and #list_items > 0 then
			guidance = "Move its KEYS ("
				.. table.concat(string_keys, ", ")
				.. ") AND its list entries ("
				.. table.concat(list_items, ", ")
				.. ")\n— all of them server names — into `lsp_deps`, then delete `external_lsp_deps`."
		elseif #string_keys > 0 then
			guidance = "Move its KEYS ("
				.. table.concat(string_keys, ", ")
				.. ") — the server names, not the\n"
				.. "executable values — into `lsp_deps`, then delete `external_lsp_deps`."
		elseif #list_items > 0 then
			guidance = "It now holds a LIST ("
				.. table.concat(list_items, ", ")
				.. ") — those are already the\n"
				.. "server names; move them into `lsp_deps` and delete `external_lsp_deps`."
		else
			guidance = "It is empty or not a map — delete `external_lsp_deps` from user/settings.lua."
		end
		-- (Scheduled: the notifier plugin isn't loaded this early; the default
		-- notify still lands in :messages.)
		vim.schedule(function()
			vim.notify(
				"`external_lsp_deps` was removed: non-Mason servers are now discovered\nfrom $PATH. " .. guidance,
				vim.log.levels.WARN,
				{ title = "core.settings" }
			)
		end)
	end
end

return M

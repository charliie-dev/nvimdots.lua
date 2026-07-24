-- Discovery-first tool resolution (RFC: ayamir/nvimdots#1293): $PATH → Mason
-- install → aggregated missing-tool warning, with Mason as an optional backend
-- and `M.resolve` as the shared loop.
--
-- Only mason.setup() (lazy-loaded) puts Mason's bin dir on $PATH, so resolve()
-- keeps it there first (`M.ensure_mason_on_path`, idempotent membership
-- check) — appended, not prepended, so a system copy still wins. A bare-name
-- spawn that bypasses `M.resolve` must call `M.ensure_mason_on_path()` itself
-- or use `M.find_executable`.
local M = {}

-- Fallback when `settings.tool_install_timeout` is missing or non-positive;
-- lua/core/settings.lua's doc comment references this constant by name.
local DEFAULT_TOOL_INSTALL_TIMEOUT_MS = 300000

-- ONE source for the parity-sweep deadline shared by the two per-filetype
-- consumers (mason-lspconfig's LSP sweep, nvim-lint's linter sweep): every
-- deferred dep is classified at most this long after its resolve pass even if
-- its filetype never opens. The two sweeps deliberately DIFFER in mechanics —
-- lint arms a CursorHold idle gate plus a fallback timer and warms module
-- loads one per tick (linter modules may block at load: golangcilint runs its
-- binary), while the LSP sweep is a plain generation-guarded timer (its
-- module loads are cheap) — only the deadline itself is common.
M.SWEEP_DELAY_MS = 120000

---Split a caller-supplied name spec into valid names and the raw entries
---dropped: string → singleton; table → non-string/empty entries collected
---into `invalid` (config mistakes the caller may report), nil holes skipped
---(maxn, so a hole can't truncate the list); anything else → no names. The
---ONE definition of what counts as a valid dep entry.
---@param names any @Executable name(s) as callers pass them.
---@return string[] valid
---@return any[] invalid @Raw non-nil dropped entries, in order.
local function split_dep_names(names)
	if type(names) == "string" then
		-- An empty string is invalid, same as in the table branch below — route
		-- it to `invalid` so the ONE validity definition holds for both shapes
		-- (a blank string must never read as a valid, label-less dep).
		if names == "" then
			return {}, { "" }
		end
		return { names }, {}
	end
	if type(names) ~= "table" then
		return {}, {}
	end
	local out, invalid = {}, {}
	for i = 1, table.maxn(names) do
		local name = names[i]
		if type(name) == "string" and name ~= "" then
			out[#out + 1] = name
		elseif name ~= nil then
			invalid[#invalid + 1] = name
		end
	end
	return out, invalid
end
M.split_dep_names = split_dep_names

---Keep a value only when it is a string: probe/config results are untrusted
---external shapes, and every non-string sanitizes to nil.
---@param value any
---@return string|nil
local function str_or_nil(value)
	return type(value) == "string" and value or nil
end

---Locate the first of the given executables: $PATH, then Mason's bin dir
---(reachable before mason.setup() prepends it). First-found by design:
---callers pass alternates for one tool, not a list of required binaries.
---@param names string|string[] @Executable name(s), probed in order.
---@return string|nil @Absolute path of the first name found, or nil.
function M.find_executable(names)
	names = (split_dep_names(names))
	for _, name in ipairs(names) do
		local path = vim.fn.exepath(name)
		if path ~= "" then
			return path
		end
	end
	local root = M.mason_root()
	if root then
		for _, name in ipairs(names) do
			-- exepath() also resolves the Windows `.cmd` shim extension.
			local path = vim.fn.exepath(root .. "/bin/" .. name)
			if path ~= "" then
				return path
			end
		end
	end
	return nil
end

-- Hits only: rtp grows as lazy.nvim loads plugins, so a cached miss would go
-- stale mid-session.
local module_path_cache = {}

---Locate a module file on the paths require() uses, without executing it:
---package.path plus the runtimepath loader (covers `user.*`).
---@param module string
---@return string|nil
function M.module_path(module)
	if module_path_cache[module] then
		return module_path_cache[module]
	end
	-- package.searchpath is a Lua 5.2 extension LuaJIT ships (our runtime), but a
	-- PUC-Lua 5.1 nvim build lacks it; guard so module resolution degrades to
	-- vim.loader.find (nvim core, always present) instead of hard-erroring there.
	local path = package.searchpath and package.searchpath(module, package.path) or nil
	if not path then
		-- vim.loader.find covers foo.lua and foo/init.lua without an rtp glob.
		local found = vim.loader.find(module)[1]
		path = found and found.modpath or nil
	end
	module_path_cache[module] = path
	return path
end

-- First load error per module: a re-require after a failed load only says
-- "previous error loading module", so the original message must be kept.
local broken_module_reason = {}

---Require a module, distinguishing "missing" from "exists but broken": a file
---present on the search paths that throws at load is notified (once) and
---keeps `exists` true, so callers don't misread it as an unknown name.
---@param module string
---@param title? string @Notification title for broken-module load errors.
---@return boolean ok @Whether the require succeeded.
---@return any value @The module's value when ok, else nil.
---@return boolean exists @Whether the module file exists on the search paths.
---@return string|nil reason @The load error when the module exists but is broken.
function M.load_module_or_report(module, title)
	local ok, value = pcall(require, module)
	if ok then
		return true, value, true
	end
	if not M.module_path(module) then
		return false, nil, false
	end
	local reason = broken_module_reason[module]
	if not reason then
		reason = tostring(value)
		broken_module_reason[module] = reason
		vim.notify(
			string.format("Failed to load `%s`:\n%s", module, reason),
			vim.log.levels.ERROR,
			{ title = title or "tools" }
		)
	end
	return false, nil, true, reason
end

---Enforce the no-fall-through contract for a locally loaded config: a broken
---candidate raises its reason verbatim (it must never read as success to the
---resolver — that would suppress both the warning and the install fallback),
---and a loaded value outside the accepted shapes raises a labeled shape
---error. Returns the value (nil = no config exists) once safe to consume.
---@param value any @The loaded config value (nil when no candidate exists).
---@param broken_reason string|nil @From a candidate-loader (DAP's load_client_config / LSP's server_info).
---@param opts { label: string, expected: string, shapes: table<string, boolean> }
---@return any value
function M.usable_or_raise(value, broken_reason, opts)
	if broken_reason then
		M.raise_verbatim(broken_reason)
	end
	if value ~= nil and not opts.shapes[type(value)] then
		M.raise_verbatim(string.format("%s must return %s (got `%s`)", opts.label, opts.expected, type(value)))
	end
	return value
end

---Keep Mason's bin dir on $PATH (see the file header). Idempotent via the
---exact-entry membership check each call (one plain find over $PATH): a
---set-once flag would skip exactly the cases the recheck exists for — a
---$PATH something overwrote mid-session, and a root that switched once
---mason.setup applied a different one (see mason_root). APPEND-ONLY on
---purpose: identical strings in an externally mutable list admit no robust
---ownership proof, so nothing is ever removed — and per Mason PATH mode
---(mason 2.x semantics) nothing needs to be: the default prepend puts the
---new root's bin ahead of any stale appended entry on a switch, and append
---mode's tail ordering is the user's own choice (same-name shadowing until
---restart accepted). KNOWN DEVIATION: mason's `PATH = "skip"` is NOT honored
---here — deliberately. The resolver's availability verdicts (find_executable,
---consulted by every resolve()) and its consumers' bare-name spawns
---(conform/nvim-lint commands, LSP cmds) must AGREE, and this append is what
---keeps them agreeing; honoring skip would classify a Mason-only tool as
---available while its spawn fails, turning the aggregated report into a lie.
---Honoring skip coherently requires absolute-command configuration across
---every bare-spawn consumer — a cross-cutting change tracked as follow-up
---work, out of this module's scope.
function M.ensure_mason_on_path()
	local root = M.mason_root()
	if not root then
		return
	end
	local bin = root .. "/bin"
	local sep = require("core.global").is_windows and ";" or ":"
	local path = vim.env.PATH or ""
	-- Exact-entry membership check (mason.setup may have prepended it): wrap
	-- both sides in the separator; plain find — $PATH may hold magic chars.
	if not (sep .. path .. sep):find(sep .. bin .. sep, 1, true) then
		vim.env.PATH = path ~= "" and (path .. sep .. bin) or bin
	end
end

---Lazy mason-registry thunk for resolve() specs — the ONE copy (dap and the
---runtime-tools resolver share it, so a change to the load guard cannot
---drift between consumers). Passed as a spec `registry` value: phase 1 never
---calls it — phase 2 and the retry paths resolve it only once leftovers
---exist, so a fully-provisioned setup never loads mason-registry.
---@return table|nil
function M.default_registry()
	local ok, resolved = pcall(require, "mason-registry")
	return ok and resolved or nil
end

---Resolve the first of the given executable names, or `error()` with the
---install hint — at level 0 so the message carries no "file:line:" prefix.
---@param names string|string[] @Executable name(s), probed in order.
---@param hint string @Actionable install guidance appended to the error.
---@return string @Absolute path of the first name found.
function M.exepath_or_error(names, hint)
	local path = M.find_executable(names)
	if path then
		return path
	end
	local shown = (split_dep_names(names))
	local label = #shown > 0 and table.concat(shown, "/") or "<invalid executable spec>"
	error(string.format("%s not found on $PATH or in Mason's bin dir; %s", label, hint), 0)
end

-- Real chunkname prefixes error() prepends, most specific first. A lazy
-- catch-all would also eat the leading prose of a prefix-less level-0 raise
-- whose message contains ":<digits>: " (e.g. "parse failed at 12:30: ...").
local CHUNK_PREFIXES = {
	'^%[string "[^\n]*"%]:%d+: ',
	"^%[C%]:%d+: ",
	"^[^\n]-%.lua:%d+: ",
}

---Normalize a pcall-captured error: a raise_verbatim sentinel yields its
---reason untouched; a string loses the "chunkname:line: " prefix error() adds
---(only shapes that ARE chunknames — a custom non-.lua chunk keeps its
---prefix, which is more information, never less); anything else is dropped.
---@param err any
---@return string|nil
local function error_reason(err)
	if type(err) == "table" and type(err.reason) == "string" then
		return err.reason
	end
	if type(err) ~= "string" then
		return nil
	end
	for _, pattern in ipairs(CHUNK_PREFIXES) do
		local stripped, hits = err:gsub(pattern, "")
		if hits > 0 then
			return stripped
		end
	end
	return err
end

-- Private brand for raise_verbatim errors: only sentinels carrying this key
-- count as config-layer failures — a config that happens to throw its own
-- `{ reason = ... }` table stays an ordinary error.
local VERBATIM = {}

---Raise a config failure whose message must reach the warning verbatim: it may
---itself start with a "path:line:" that position stripping would eat. The
---resolver also treats this sentinel as a config-layer error: a "validates"
---local config raising it is reported immediately, never answered with an
---install (an install can't fix a broken config).
---@param reason string
function M.raise_verbatim(reason)
	-- selene: allow(incorrect_standard_library_use) -- error() does accept any value
	error({ reason = reason, [VERBATIM] = true })
end

---Aggregate tools that could not be set up into one deferred warning, in two
---sections: `mark` (install it / config failed) and `mark_unknown`
---(unrecognized name — fix the config, don't install).
---@class ToolCollector
---@field mark fun(name: string, reason?: string, provisional?: boolean, final?: boolean) @Record an unresolved tool;
---  a provisional reason is a placeholder a later concrete failure may replace.
---@field mark_unknown fun(name: string) @Record an unrecognized name (typo / outdated / unsupported).
---@field track fun(pkg: table, name: string, recheck: (fun(): boolean), on_ready?: fun(), fail_reason?: string)
---@field is_unsettled fun(name: string): boolean @Whether an in-flight tracked install still owns the name.
---@field retract fun(name: string) @A success contradicts any standing `missing`-bucket entry for the name.
---@field done fun() @Flush the aggregated warning once all tracked installs settle.
---@param title string @Notification title identifying the subsystem.
---@param timeout_ms? number @Deadline before the warning is flushed despite unsettled installs.
---@return ToolCollector
local function missing_collector(title, timeout_ms)
	-- ONE record per name across both report buckets — upgrades, the
	-- placeholder retraction, the bucket migration, and a success deleting the
	-- record outright each mutate a single record instead of five parallel
	-- structures in lockstep.
	--   bucket      "missing" (install it / config failed) | "unknown" (typo).
	--   reason      rendered in the missing section only.
	--   provisional the reason is a placeholder (generic install-timeout /
	--               registry-refresh note): a later concrete failure may
	--               upgrade it or the migration may re-bucket the name.
	--   final       from an actual ATTEMPTED-AND-FAILED configure/install:
	--               never migrated to the typo bucket (a name that resolved
	--               far enough to run is real; a late "unknown" verdict would
	--               be the misclassification).
	--   emitted     already notified; cleared to re-notify a changed record.
	---@type table<string, { bucket: "missing"|"unknown", reason: string|nil, provisional: boolean|nil, final: boolean|nil, emitted: boolean|nil }>
	local entries = {}
	local queued = {}
	-- Tracked installs whose "closed" callback hasn't run yet
	-- (name -> { reason = phase-1 fail_reason or false }); each entry owns a
	-- defer_fn timer that settles it if the closed callback never does.
	-- Deliberately separate from `entries`: different lifecycle (install
	-- tracking, not reporting).
	local unsettled = {}
	local flush_scheduled = false
	local announce_scheduled = false
	-- Forward declaration: add/add_unknown re-flush after an upgrade/migration.
	local flush

	-- Dedup across both buckets; non-string names are tostring()'d, nil/empty dropped.
	local function normalize(name)
		if name == nil or name == "" then
			return nil
		end
		return type(name) == "string" and name or tostring(name)
	end
	local function add(name, reason, is_provisional, is_final)
		name = normalize(name)
		if name == nil then
			return
		end
		local entry = entries[name]
		if entry == nil then
			entries[name] = {
				bucket = "missing",
				reason = (type(reason) == "string" and reason ~= "") and reason or nil,
				provisional = is_provisional or nil,
				final = is_final or nil,
			}
			return
		end
		if is_final then
			entry.final = true
		end
		-- Already recorded: a concrete reason may replace a placeholder one
		-- (generic timeout/refresh note, or a reason-less mark) and re-notify —
		-- also for a name sitting in the UNKNOWN bucket, where the reason is
		-- unread but the re-emission stands ("unknown wins once assigned": the
		-- bucket never flips back).
		if type(reason) ~= "string" or reason == "" or reason == entry.reason then
			return
		end
		-- The first REAL reason wins; later ones never overwrite it.
		if entry.reason ~= nil and not entry.provisional then
			return
		end
		entry.reason = reason
		entry.provisional = is_provisional or nil
		entry.emitted = nil
		flush()
	end
	local function add_unknown(name)
		name = normalize(name)
		if name == nil then
			return
		end
		local entry = entries[name]
		if entry == nil then
			entries[name] = { bucket = "unknown" }
			return
		end
		-- Bucket migration: a name parked in `missing` under a placeholder
		-- reason (registry-refresh timeout) may classify as unknown once the
		-- late refresh completes — move it so a typo doesn't keep stale
		-- install guidance. Entries with a real reason never migrate, and
		-- neither does anything flagged `final` (attempted-and-failed) — a
		-- reason-LESS real failure must not turn into typo guidance.
		if entry.bucket == "unknown" or entry.final or not (entry.provisional or entry.reason == nil) then
			return
		end
		entry.bucket = "unknown"
		entry.reason = nil
		entry.provisional = nil
		entry.emitted = nil
		flush()
	end

	-- Coalesced corrective INFO for retracted-after-emission entries.
	local retract_queue = {}
	local retract_scheduled = false
	local function retract(name)
		name = normalize(name)
		if name == nil then
			return
		end
		local entry = entries[name]
		-- Only the missing bucket: an `unknown` verdict (typo) is not contradicted
		-- by a configure succeeding under a different resolution path.
		if entry == nil or entry.bucket ~= "missing" then
			return
		end
		local seen = entry.emitted
		entries[name] = nil
		if not seen then
			return -- never notified: silently dropping it IS the correction
		end
		retract_queue[#retract_queue + 1] = name
		if retract_scheduled then
			return
		end
		retract_scheduled = true
		vim.schedule(function()
			retract_scheduled = false
			if #retract_queue == 0 then
				return
			end
			table.sort(retract_queue)
			vim.notify(
				"Now installed and configured (the earlier warning about these no longer applies): "
					.. table.concat(retract_queue, ", "),
				vim.log.levels.INFO,
				{ title = title }
			)
			retract_queue = {}
		end)
	end

	local function render(name)
		local entry = entries[name]
		local reason = entry and entry.reason
		return reason and (name .. " — " .. reason) or name
	end

	-- Emit names not yet notified, coalesced per event-loop tick. Gated while
	-- installs are pending unless forced (done() and per-install timers force:
	-- their records are final); `emitted` lets late failures still notify.
	function flush(force)
		if not force and next(unsettled) ~= nil then
			return
		end
		if flush_scheduled then
			return
		end
		flush_scheduled = true
		vim.schedule(function()
			flush_scheduled = false
			-- Un-emitted records only; each batch is sorted below, so the
			-- pairs() order never reaches the user.
			local missing_new, unknown_new = {}, {}
			for name, entry in pairs(entries) do
				if not entry.emitted then
					entry.emitted = true
					if entry.bucket == "missing" then
						missing_new[#missing_new + 1] = name
					else
						unknown_new[#unknown_new + 1] = name
					end
				end
			end
			if #missing_new == 0 and #unknown_new == 0 then
				return
			end
			local sections = {}
			if #missing_new > 0 then
				table.sort(missing_new)
				local lines = {}
				for _, name in ipairs(missing_new) do
					lines[#lines + 1] = render(name)
				end
				sections[#sections + 1] = "The following tools could not be set up automatically.\n"
					.. "Install them / ensure they are on $PATH, or check their configuration\n"
					.. "for errors:\n  • "
					.. table.concat(lines, "\n  • ")
					.. "\n\nMason installs are picked up automatically; after installing a tool\n"
					.. "outside Mason, run :ToolsRetry or restart Neovim."
			end
			if #unknown_new > 0 then
				table.sort(unknown_new)
				sections[#sections + 1] = "The following names are not recognized (likely a typo, or an outdated\n"
					.. "or unsupported name) — correct or remove them from your config:\n  • "
					.. table.concat(unknown_new, "\n  • ")
			end
			vim.notify(table.concat(sections, "\n\n"), vim.log.levels.WARN, { title = title })
		end)
	end

	return {
		mark = add,
		mark_unknown = add_unknown,
		---An install tracked here whose "closed" callback hasn't run yet (and
		---whose deadline hasn't settled it): such a name is owned by that
		---callback, so hand-off retries leave it alone.
		is_unsettled = function(name)
			return unsettled[name] ~= nil
		end,
		retract = retract,
		track = function(pkg, name, recheck, on_ready, fail_reason)
			-- Attach to an in-flight OPEN install handle instead of starting a
			-- duplicate (install() asserts; once("closed") never fires on a closed one).
			local handle
			if type(pkg) == "table" and type(pkg.get_install_handle) == "function" then
				local ok, opt = pcall(function()
					return pkg:get_install_handle()
				end)
				if ok and type(opt) == "table" and type(opt.if_present) == "function" then
					opt:if_present(function(h)
						local ok_closed, closed = pcall(function()
							return h:is_closed()
						end)
						if ok_closed and not closed then
							handle = h
						end
					end)
				end
			end

			-- Only a self-started install is announced in the "Installing N tool(s)" INFO.
			local started_here = handle == nil
			if not handle then
				local ok, h = pcall(function()
					return pkg:install()
				end)
				if not ok or type(h) ~= "table" or type(h.once) ~= "function" then
					-- A synchronous install() throw is the only failure detail there is.
					add(name, fail_reason or (not ok and error_reason(h) or nil), nil, true)
					return
				end
				handle = h
			elseif type(handle.once) ~= "function" then
				-- Shared handle isn't usable (unexpected shape); mark rather than hang.
				add(name, fail_reason, nil, true)
				return
			end

			-- Only the first in-flight track for a name creates the entry: a
			-- repeat (re-resolve pass / shared-handle piggyback) must not add a
			-- second settle against one install. `track` is only ever called
			-- with a non-empty string name (start_install), so `unsettled`
			-- membership IS the whole accounting — the flush gate reads it.
			local first_track = unsettled[name] == nil
			if first_track then
				unsettled[name] = { reason = fail_reason or false }
				-- One timer per tracked install, settling only its own entry
				-- (a no-op when the closed callback got there first), so a
				-- late-tracked install always keeps its full window. Without
				-- a configured timeout the entry settles via "closed" only.
				if type(timeout_ms) == "number" and timeout_ms > 0 then
					vim.defer_fn(function()
						local entry = unsettled[name]
						if entry == nil then
							return
						end
						unsettled[name] = nil
						-- The generic note is a placeholder a later concrete
						-- failure may upgrade (see add()).
						add(
							name,
							type(entry.reason) == "string" and entry.reason
								or "Mason install did not finish within the timeout (check :Mason for progress)",
							entry.reason == false
						)
						-- This entry is final: force past the unsettled gate.
						flush(true)
					end, timeout_ms)
				end
			end
			-- "closed" fires in a fast event context: hop to the main loop. recheck/
			-- on_ready are pcall'd so a throw can't suppress flush; clearing the
			-- entry is a no-op when the deadline already settled this install,
			-- but on_ready still runs.
			local registered, reg_err = pcall(
				handle.once,
				handle,
				"closed",
				vim.schedule_wrap(function()
					unsettled[name] = nil
					local rc_ok, available = pcall(recheck)
					if rc_ok and available then
						if type(on_ready) == "function" then
							-- A configure throw after the install must still reach the
							-- warning. (A nil error_reason with nil fail_reason can
							-- still strand a deadline placeholder here — rare,
							-- pre-existing shape shared with the branch below.)
							local ready_ok, ready_err = pcall(on_ready)
							if not ready_ok then
								add(name, error_reason(ready_err) or fail_reason, nil, true)
							end
						end
					elseif fail_reason ~= nil then
						add(name, fail_reason, nil, true) -- a concrete reason upgrades any placeholder
					elseif entries[name] and entries[name].provisional then
						-- The deadline timer already parked this name under the
						-- "did not finish within the timeout" note — now known
						-- FALSE: the install finished (and failed) with no reason
						-- to offer. Retract the placeholder and re-emit the bare
						-- name (accurate: unknown failure) instead of pointing
						-- the user at :Mason progress that will never come.
						local entry = entries[name]
						entry.reason = nil
						entry.provisional = nil
						entry.final = true -- retraction IS an attempted-and-failed verdict
						entry.emitted = nil -- the trailing flush re-emits the corrected entry
					else
						add(name, nil, nil, true)
					end
					flush()
				end)
			)
			-- once() threw: undo only what THIS track added, or a failed piggyback
			-- would clear another caller's in-flight entry.
			if not registered then
				if first_track then
					unsettled[name] = nil
				end
				add(name, fail_reason or error_reason(reg_err), nil, true)
			elseif started_here and type(name) == "string" and name ~= "" then
				-- Announce only self-started installs, only once registration stuck.
				queued[#queued + 1] = name
			end
		end,
		done = function()
			-- One coalesced INFO per batch so a first launch shows progress;
			-- drained after announcing so a later done() can't re-announce.
			if #queued > 0 and not announce_scheduled then
				announce_scheduled = true
				vim.schedule(function()
					announce_scheduled = false
					if #queued == 0 then
						return
					end
					table.sort(queued)
					local message = string.format(
						"Installing %d tool(s) via Mason in the background; each is configured\n"
							.. "automatically once its install finishes (relaunch if one isn't picked up):\n  • %s",
						#queued,
						table.concat(queued, "\n  • ")
					)
					queued = {}
					vim.notify(message, vim.log.levels.INFO, { title = title })
				end)
			end
			-- done()'s records are final: force past the unsettled gate.
			flush(true)
		end,
	}
end

---Whether the registry's source specs are all on disk. On API drift err toward
---false: resolve() then refreshes redundantly (a no-op), and package_for_binary
---rebuilds instead of freezing — both err toward correctness.
---@param registry table|nil @The mason-registry module (or nil).
---@return boolean
local function registry_bootstrapped(registry)
	if not registry or registry.sources == nil then
		return false
	end
	local ok, all_installed = pcall(function()
		return registry.sources:is_all_installed()
	end)
	if not ok then
		return false
	end
	return all_installed == true
end

-- Frozen bin -> package index (see package_for_binary below).
local bin_to_package = nil
-- Unfrozen scans stay re-buildable by design (self-heal after a late
-- refresh), but within ONE event-loop tick nothing can change: memoize per
-- tick so a batch of lookups decodes registry.json once, not N times.
local unfrozen_index = nil

---Find the Mason package shipping the given binary, via a lazily-built
---bin -> package index over the registry specs: tool name, binary, and
---package name may all differ (cmake_format -> cmake-format -> cmakelang).
---@param registry table @The mason-registry module.
---@param binary string @Executable name to look up.
---@return string|nil @Mason package name shipping that binary, or nil.
local function package_for_binary(registry, binary)
	-- Freeze the index only once the registry is FULLY bootstrapped:
	-- get_all_package_specs() silently skips uninstalled sources, and a frozen
	-- partial index would outlive resolve()'s re-refresh self-heal. (A source
	-- appended at runtime after the freeze is out of scope.)
	if bin_to_package == nil then
		if unfrozen_index then
			return unfrozen_index[binary]
		end
		local index = {}
		local populated = false
		local ok, specs = pcall(registry.get_all_package_specs)
		if ok and type(specs) == "table" then
			for _, spec in ipairs(specs) do
				if type(spec) == "table" and type(spec.name) == "string" and type(spec.bin) == "table" then
					for bin_name in pairs(spec.bin) do
						if index[bin_name] == nil then
							index[bin_name] = spec.name
							populated = true
						end
					end
				end
			end
		end
		if populated and registry_bootstrapped(registry) then
			bin_to_package = index
		else
			-- Partial/uncertain scan: consult what was found, keep it only for
			-- the current tick.
			unfrozen_index = index
			vim.schedule(function()
				unfrozen_index = nil
			end)
			return index[binary]
		end
	end
	return bin_to_package[binary]
end

---Executable name(s) a Mason package provides, from its spec. Without a `bin`
---table prefer `pkg.name`: the subsystem name can differ (python -> debugpy).
---@param pkg table @A mason-registry Package object.
---@param fallback string @Last-resort name when even `pkg.name` is absent.
---@return string[]
function M.package_binaries(pkg, fallback)
	local bins = (type(pkg.spec) == "table" and type(pkg.spec.bin) == "table") and vim.tbl_keys(pkg.spec.bin) or {}
	-- tbl_keys order is unspecified; sort so multi-bin probes stay stable.
	table.sort(bins)
	if #bins == 0 then
		bins = { type(pkg.name) == "string" and pkg.name or fallback }
	end
	return bins
end

---Mason's install root WITHOUT loading Mason (this runs from every resolve()):
---a set-up mason.settings always wins — checked LIVE each call, because the
---module may load long after the first resolve cached a fallback and call
---timing must not invert the priority; gated on mason.has_setup because
---mason-registry requires mason.settings at load with the DEFAULTS, and only
---setup() applies a user's custom root — then $MASON (read live each call,
---like every other branch: a stale export corrected via :let must take
---effect, and a latched dead path must not shadow the guess forever), then
---the default data-dir guess. The guess only counts when no `user.configs.mason`
---override exists (the one supported home for a custom root) and is never
---cached; every returned root is re-checked for existence each call (the dir
---appears after the first install). Kept public deliberately so these
---priority semantics stay independently testable from outside the module
---(test hook); no external runtime caller today.
---@return string|nil
-- The user-override existence check is memoized separately from module_path's
-- hit-only cache: it merely gates the default-dir guess below, and a user
-- adding user/configs/mason mid-session needs a restart for a new root
-- anyway — so unlike a general module miss, staleness here is harmless.
local mason_override_absent = nil
function M.mason_root()
	local mason = package.loaded["mason"]
	local settings = package.loaded["mason.settings"]
	if
		type(mason) == "table"
		and mason.has_setup == true
		and type(settings) == "table"
		and type(settings.current) == "table"
		and type(settings.current.install_root_dir) == "string"
	then
		-- Presence decides the branch, existence decides the return: a
		-- configured-but-not-yet-created root yields nil, it must NOT fall
		-- back to a wrong root.
		local root = settings.current.install_root_dir
		return vim.uv.fs_stat(root) and root or nil
	end
	local env_root = type(vim.env.MASON) == "string" and vim.env.MASON ~= "" and vim.env.MASON or nil
	if env_root then
		return vim.uv.fs_stat(env_root) and env_root or nil
	end
	-- Never require() mason.settings here — it lazy-loads all of mason.nvim
	-- during a pure discovery probe, defeating "Mason optional".
	local guess = vim.fn.stdpath("data") .. "/mason"
	if mason_override_absent == nil then
		mason_override_absent = M.module_path("user.configs.mason") == nil
	end
	if mason_override_absent and vim.uv.fs_stat(guess) then
		return guess
	end
	return nil
end

-- One collector per title so a subsystem that resolves in batches (nvim-lint,
-- per filetype) aggregates one warning instead of one per batch.
local collectors_by_title = {}

-- Install hand-off: resolve() sessions whose deps are still waiting for a tool
-- to appear. Each entry pairs a spec with its pending set so a later Mason
-- install event or :ToolsRetry can finish the configure without a restart.
local sessions = {}

---Deregister a session once nothing is pending (leak-free bookkeeping). Sole
---owner of removal — called from every path that empties a pending set, so
---iterations over `sessions` never race a second remover.
---@param session table
local function drop_session_if_done(session)
	if next(session.pending) ~= nil then
		return
	end
	for index = #sessions, 1, -1 do
		if sessions[index] == session then
			table.remove(sessions, index)
			return
		end
	end
end

---Drop every pending session recorded under `title`: a consumer calls this
---when it rebuilds its resolve state (re-source), because the superseded
---run's sessions hold stale configure closures that retry paths would still
---invoke. The new run re-resolves every dep it still cares about, so
---dropped pending names are re-covered, not lost. (The sweep timers guard
---the same hazard with vim.g generation tokens; sessions need this explicit
---drop instead — multiple LIVE sessions per title are legal within one run,
---so a per-title singleton rule can't work.)
---@param title string
function M.drop_sessions(title)
	for index = #sessions, 1, -1 do
		if sessions[index].title == title then
			table.remove(sessions, index)
		end
	end
end

---Gated late-configure across sessions: for every pending name accepted by
---`eligible`, run the session's configure — at most one SUCCESS per name (the
---pending set is the gate; a failure keeps the name recoverable) — and report
---each subsystem's batch in one INFO. An emptied session drops out via the
---configure path itself (drop_session_if_done); descending order keeps the
---iteration safe across that removal.
---@param eligible fun(session: table, name: string): boolean
local function retry_pending(eligible)
	local configured_by_title = {}
	local failed_by_title = {}
	for index = #sessions, 1, -1 do
		local session = sessions[index]
		for _, name in ipairs(vim.tbl_keys(session.pending)) do
			-- Re-check pending: an earlier name's configure may have consumed it.
			if session.pending[name] ~= nil and eligible(session, name) then
				local ok, reason = session.configure(name)
				if ok then
					local bucket = configured_by_title[session.title] or {}
					bucket[#bucket + 1] = name
					configured_by_title[session.title] = bucket
				else
					-- A silent failed retry is indistinguishable from "retry
					-- never considered this name" — and the collector's
					-- first-real-reason-wins gate absorbs the fresh reason,
					-- so this WARN is the only accurate signal. nil reasons
					-- render as the bare name (never concat nil).
					local bucket = failed_by_title[session.title] or {}
					bucket[#bucket + 1] = reason and (name .. " — " .. reason) or name
					failed_by_title[session.title] = bucket
				end
			end
		end
	end
	for title, names in pairs(configured_by_title) do
		table.sort(names)
		vim.notify("Configured after install: " .. table.concat(names, ", "), vim.log.levels.INFO, { title = title })
	end
	for title, lines in pairs(failed_by_title) do
		table.sort(lines)
		vim.notify(
			"Retry failed (still pending):\n  • " .. table.concat(lines, "\n  • "),
			vim.log.levels.WARN,
			{ title = title }
		)
	end
end

-- Attached once per session lifetime; each subscription pcall'd SEPARATELY
-- and flagged SEPARATELY (mason-registry API-drift guard): with one shared
-- flag, a throw from the second subscription after the first registered
-- would leave the flag unset, and the next attach would register the install
-- handler TWICE — duplicate retry_pending walks on every later install. A
-- still-false half retries on the next attach; no events at all = status
-- quo: the tool is picked up on the next launch.
local install_events_attached = false
local update_events_attached = false

---A pending name's declared bare binaries, probed on $PATH / Mason's bin —
---the first (cheapest) availability evidence BOTH install hand-off paths
---share (the Mason install event and :ToolsRetry). The is_unsettled
---ownership guard deliberately stays at each call site: the two paths
---interleave DIFFERENT extra evidence around this probe (the event handler
---checks the installed package's name first; retry layers registry-derived
---binaries and the validates re-run after), so only the probe itself is the
---common core.
---@param session table
---@param name string
---@return boolean
local function pending_bins_available(session, name)
	local bins_ok, bins = pcall(session.spec.binaries_of, name, nil)
	return bins_ok and M.find_executable(bins) ~= nil
end

---Subscribe to Mason install successes so a package installed mid-session by
---ANY means (resolver-started, :MasonInstall, the :Mason UI) finishes the
---pending configure of every subsystem that waited for it. Never require()s
---mason-registry itself — callers pass a registry they already hold, keeping
---"a fully-provisioned setup never loads Mason" intact.
---@param registry table|nil @The mason-registry module (or nil).
function M.attach_registry_events(registry)
	if install_events_attached and update_events_attached then
		return
	end
	if type(registry) ~= "table" or type(registry.on) ~= "function" then
		return
	end
	if not install_events_attached then
		install_events_attached = pcall(function()
			registry:on(
				"package:install:success",
				-- The emitter fires from the install handle's lifecycle (fast event
				-- context): hop to the main loop before touching consumer configs.
				vim.schedule_wrap(function(pkg)
					local pkg_name = type(pkg) == "table" and type(pkg.name) == "string" and pkg.name or nil
					if not pkg_name then
						return
					end
					retry_pending(function(session, name)
						-- An install still in flight is owned by its closed callback.
						if session.is_unsettled(name) then
							return false
						end
						local ok, mapped = pcall(session.spec.package_of, name, registry)
						if ok and mapped == pkg_name then
							return true
						end
						return pending_bins_available(session, name)
					end)
				end)
			)
		end)
	end
	if not update_events_attached then
		update_events_attached = pcall(function()
			registry:on("update:success", function()
				-- SYNCHRONOUS on purpose: mason emits this inside the update
				-- success path, before callers' callbacks run — a scheduled clear
				-- would leave a same-tick window still reading the stale frozen
				-- index. Clearing two locals is pure Lua, fast-event-safe; the
				-- next lookup rebuilds (and re-freezes on a bootstrapped registry).
				-- Were upstream ever to emit this asynchronously instead, the
				-- sync clear degrades to one harmless extra rebuild.
				bin_to_package = nil
				unfrozen_index = nil
			end)
		end)
	end
end

---Re-attempt every pending dep whose tool has since appeared — the manual
---hand-off entry (:ToolsRetry) for installs done outside Mason (mise/nix/npm).
function M.retry_missing()
	retry_pending(function(session, name)
		-- An install still in flight is owned by its closed callback.
		if session.is_unsettled(name) then
			return false
		end
		local spec = session.spec
		if pending_bins_available(session, name) then
			return true
		end
		-- Function-cmd LSP servers (jsonls/yamlls) declare no bare binary:
		-- derive it from the Mason package spec even when the binary itself was
		-- installed outside Mason.
		local registry = session.resolve_registry()
		if registry then
			local ok, pkg_name = pcall(spec.package_of, name, registry)
			if ok and type(pkg_name) == "string" then
				local pkg_ok, pkg = pcall(registry.get_package, pkg_name)
				if pkg_ok and type(pkg) == "table" then
					local pkg_bins_ok, pkg_bins = pcall(spec.binaries_of, name, pkg)
					if pkg_bins_ok and M.find_executable(pkg_bins) ~= nil then
						return true
					end
				end
			end
		end
		-- Only self-VALIDATING configs may retry on config evidence alone: their
		-- configure re-checks the tool and a still-missing one fails the attempt,
		-- keeping the name pending. A generic local config (LSP) would instead
		-- enable a server whose binary is still absent.
		if spec.local_config_mode ~= "validates" or type(spec.has_local_config) ~= "function" then
			return false
		end
		local has_ok, has = pcall(spec.has_local_config, name)
		return has_ok and has == true
	end)
end

---Shared discovery-first resolution loop. For each entry in `spec.deps`:
---  0. Unrecognized name (`unknown_of`)           -> fix the config; never install.
---  1. Available (Mason-installed / on $PATH)     -> configure now.
---  2. Mason package exists but not available yet -> a "validates" local
---     config tries first; else configure if its declared bins are on $PATH;
---     else install, then configure on completion.
---  3. No Mason package but a local config exists -> configure now.
---  4. Otherwise                                  -> aggregated warning.
---
---Everything resolvable without an install configures on the load tick (before
---lazy.nvim replays the trigger); each dep is pcall-isolated. `configure` gets
---`late = true` after resolve() returned (deferred phase 2, install completion,
---async refresh) — no replayed trigger backs such a call, so the consumer must
---re-drive its own event if one is needed.
---`local_config_mode` (for a binary-less local config): nil defers to phase 2,
---"resolves" trusts it outright, "validates" lets it try and installs on
---failure — keep "validates" checks cheap (phase 1 runs on the load tick); a
---bounded probe spawn on the miss path is acceptable when it keeps config-time
---and launch-time resolution in agreement.
---@param spec {
---  title: string,
---  deps: string[],
---  registry: table|(fun(): table|nil)|nil,
---  package_of: (fun(name: string, registry: table|nil): string|nil),
---  binaries_of: (fun(name: string, pkg: table|nil): string[]),
---  unknown_of?: (fun(name: string): boolean),
---  has_local_config?: (fun(name: string): boolean),
---  local_config_mode?: "resolves"|"validates",
---  unresolvable_of?: (fun(name: string): string|nil),
---  missing_reason_of?: (fun(name: string): string|nil),
---  configure?: (fun(name: string, late: boolean)),
---  static_binaries?: boolean,
---  defer_phase2?: boolean,
---  defer?: boolean,
---}
---`unresolvable_of` (optional): a non-nil reason short-circuits the name in
---phase 1 — marked missing with that reason and flushed immediately, never
---classified against the registry (the one exception to "phase 1 never marks
---missing").
---`missing_reason_of` (optional): consulted only for the final reason-less
---missing mark in phase 2 (no package, no local config) — a string return
---annotates the aggregated warning; errors and non-strings are ignored.
---`static_binaries` (optional): declares that `binaries_of` ignores `pkg`, so
---phase 2 skips its already-on-$PATH re-probe (it would be identical to the
---one phase 1 already ran); see the comment at that probe for the accepted
---external-install race delta.
---`defer` (optional): move the WHOLE resolve off the caller's tick. The
---resolver still pays ensure_mason_on_path synchronously — deferring must not
---lose the same-tick guarantee that a replayed trigger's bare Mason spawns
---can resolve — and phase-1 configures inside the scheduled run still count
---as trigger-backed (`late = false`).
function M.resolve(spec)
	-- Every call site owns a configure (the resolver's whole job funnels into
	-- it): a missing one is a programmer error — fail at the call site instead
	-- of silently "succeeding" every configure.
	assert(type(spec.configure) == "function", "tools.resolve: spec.configure must be a function")
	local ok_settings, settings = pcall(require, "core.settings")
	local timeout_ms = (
		ok_settings
		and type(settings.tool_install_timeout) == "number"
		and settings.tool_install_timeout > 0
	)
			and settings.tool_install_timeout
		or DEFAULT_TOOL_INSTALL_TIMEOUT_MS
	local collector = collectors_by_title[spec.title]
	if not collector then
		collector = missing_collector(spec.title, timeout_ms)
		collectors_by_title[spec.title] = collector
	end

	-- False once run() returns: a configure running later (deferred phase 2,
	-- install completion, async refresh) has no replayed trigger behind it and
	-- gets `late = true`.
	local synchronous = true

	-- This call's hand-off record: phase-2 leftovers park in `pending` until a
	-- configure SUCCEEDS, so the Mason install event or :ToolsRetry can finish
	-- them later; registered in `sessions` only when leftovers exist.
	local session = {
		title = spec.title,
		spec = spec,
		pending = {},
		is_unsettled = collector.is_unsettled,
		---The spec's registry (value or lazy thunk), resolved on demand; a
		---drifted non-table result normalizes to nil (degrade, never crash).
		resolve_registry = function()
			local registry = spec.registry
			if type(registry) == "function" then
				local ok, resolved = pcall(registry)
				registry = ok and resolved or nil
			end
			return type(registry) == "table" and registry or nil
		end,
	}

	---Configure one tool; false plus the cleaned error when the config threw.
	---The third result flags a BRANDED raise_verbatim sentinel — a config-layer
	---error an install can't fix. Any other thrown value (including a config's
	---own `{ reason = ... }` table) stays an ordinary failure.
	local function try_configure(name)
		local ok, err = pcall(spec.configure, name, not synchronous)
		if ok then
			return true
		end
		return false, error_reason(err), type(err) == "table" and err[VERBATIM] == true
	end

	-- Configure one tool, surfacing a config-time error in the aggregated
	-- warning. Late calls race (install completion, the registry install event,
	-- :ToolsRetry, a late refresh finish): `pending` is the gate — the first
	-- SUCCESS clears it and later arrivals skip; a failure keeps the name
	-- recoverable. Returns true only when the configure ran and succeeded;
	-- on failure the cleaned reason and the config-layer flag ride along
	-- (phase-1 parking and the retry report consume them).
	local function do_configure(name)
		if not synchronous and session.pending[name] == nil then
			return false
		end
		local ok, reason, config_error = try_configure(name)
		if ok then
			session.pending[name] = nil
			-- A success contradicts any standing missing-report for this name
			-- (deadline/refresh placeholder, or a phase-1 failure an install fixed).
			collector.retract(name)
			drop_session_if_done(session)
			return true
		end
		collector.mark(name, reason, nil, true)
		return false, reason, config_error
	end
	session.configure = do_configure

	-- Phase-1 "validates" failures, surfaced by phase 2 without re-running the
	-- config. One record per failed name: `reason` (string or nil for a
	-- message-less failure) and `config_error` (a raise_verbatim config-layer
	-- error an install can't fix). Record EXISTENCE is the failure mark.
	local validates = {}
	---@param name string
	---@return string|nil
	local function validate_reason(name)
		local record = validates[name]
		return record and record.reason or nil
	end

	-- Install `pkg`, configure on completion; failures keep the phase-1 reason.
	local function start_install(pkg, name)
		local reason = validate_reason(name)
		collector.track(pkg, name, function()
			return pkg:is_installed() or M.find_executable(spec.binaries_of(name, pkg)) ~= nil
		end, function()
			do_configure(name)
		end, reason)
	end

	---Phase 1 — configure a dep resolvable without the Mason registry ($PATH,
	---self-resolving local config, or a succeeding "validates" resolver).
	---False = needs the registry (phase 2). Never marks missing, stays same-tick.
	---@param name string
	---@return boolean handled
	local function configure_available(name)
		if M.find_executable(spec.binaries_of(name, nil)) ~= nil then
			local ok, _, config_error = do_configure(name)
			-- A failed configure whose binary IS on $PATH parks for the retry
			-- paths (pending_bins_available re-accepts it, so :ToolsRetry and
			-- the install event can finish it after the cause is fixed) —
			-- except a raise_verbatim config-layer error, which no install or
			-- retry can fix: the mark above is its final report, mirroring
			-- resolve_missing's report-immediately policy.
			if not ok and not config_error then
				session.pending[name] = true
			end
			return true
		end
		-- Both local-config modes gate on the same lookup: evaluate it once and
		-- let the mutually-exclusive mode pick the branch.
		local mode = spec.local_config_mode
		if (mode == "resolves" or mode == "validates") and spec.has_local_config and spec.has_local_config(name) then
			if mode == "resolves" then
				-- A binary-less LSP server (jsonls) still maps to a package by
				-- NAME and must reach phase 2 to install. A FAILURE here is
				-- deliberately NOT parked: every retry gate is structurally
				-- closed for a binary-less "resolves" name (no bins for
				-- pending_bins_available, no package_of mapping for the install
				-- event, validates gate closed by mode), so parking it would
				-- leak the session until restart.
				do_configure(name)
				return true
			end
			-- A "validates" config is its own resolver: let it try; remember a
			-- failure for phase 2 instead of re-running it there.
			local ok, reason, config_error = try_configure(name)
			if ok then
				-- try_configure bypasses do_configure here, so a stale emitted entry
				-- from a previous run on this shared per-title collector (collectors
				-- survive in collectors_by_title) would otherwise never retract.
				collector.retract(name)
				return true
			end
			validates[name] = {
				reason = str_or_nil(reason),
				config_error = config_error == true,
			}
		end
		return false
	end

	---Phase 2 — resolve a dep against the now-ready registry: configure an
	---installed package, install a missing one, or mark it missing/unknown.
	---@param name string
	---@param registry table|nil
	local function resolve_missing(name, registry)
		-- Judged after the refresh: unknown_of may consult the Mason mapping.
		if spec.unknown_of and spec.unknown_of(name) then
			-- A typo can't be fixed by an install: drop it from the hand-off set.
			session.pending[name] = nil
			collector.mark_unknown(name)
			return
		end

		local pkg, pkg_unknown = nil, false
		local pkg_name = spec.package_of(name, registry)
		if pkg_name and registry then
			local ok, resolved = pcall(registry.get_package, pkg_name)
			if ok then
				pkg = resolved
			else
				-- Stale mapping; reported only if nothing below resolves the tool.
				pkg_unknown = true
			end
		end

		-- The config already failed this pass. A raise_verbatim failure is a
		-- config-layer error an install can't fix: report it immediately. Only
		-- a provisioning failure (missing binary) is answered with an install.
		if validates[name] ~= nil then
			if not validates[name].config_error and pkg ~= nil and not pkg:is_installed() then
				start_install(pkg, name) -- annotates the failure reason itself
			else
				-- The "validates" configure ran and failed: attempted-and-failed,
				-- never typo-migratable.
				collector.mark(name, validate_reason(name), nil, true)
				-- A config-layer error is unfixable by install or retry (phase 1's
				-- $PATH branch never parks these — see configure_available): unpark
				-- it so the retry gates skip it and the session can drain.
				if validates[name].config_error then
					session.pending[name] = nil
				end
			end
			return
		end

		-- Installed via Mason but its binary name differs from the phase-1 probe.
		if pkg ~= nil and pkg:is_installed() then
			do_configure(name)
			return
		end

		-- The package's declared binaries are already on $PATH: system-provided,
		-- don't install a duplicate (covers function-cmd servers like jsonls).
		-- Skipped for static_binaries specs, whose binaries_of ignores `pkg`:
		-- the probe would be identical to phase 1's. Accepted delta: an external
		-- install landing inside the phase-2 window proceeds to a redundant
		-- (self-healing) Mason install instead of being caught here.
		if pkg ~= nil and not spec.static_binaries and M.find_executable(spec.binaries_of(name, pkg)) ~= nil then
			do_configure(name)
			return
		end

		-- Mason ships it but it isn't available yet: install, configure on completion.
		if pkg ~= nil then
			start_install(pkg, name)
			return
		end

		-- No installable package: local config self-validates, else mark missing/unknown.
		if spec.has_local_config and spec.has_local_config(name) then
			do_configure(name)
		elseif pkg_unknown and #spec.binaries_of(name, nil) == 0 then
			-- A stale mapping can't be fixed by an install either: drop it from
			-- the hand-off set like the unknown_of branch above.
			session.pending[name] = nil
			collector.mark_unknown(pkg_name == name and name or (pkg_name .. " (for " .. name .. ")"))
		else
			-- An optional spec hook may supply a concrete reason for an
			-- otherwise reason-less miss (e.g. DAP naming recorded mapping
			-- drift that made package_of return nil); a hook throw must not
			-- break the mark itself.
			local reason
			if type(spec.missing_reason_of) == "function" then
				local hook_ok, hook_reason = pcall(spec.missing_reason_of, name)
				reason = hook_ok and str_or_nil(hook_reason) or nil
			end
			collector.mark(name, reason)
		end
	end

	local function run()
		-- Make Mason's bin dir resolvable before any probe or spawn (see file header).
		M.ensure_mason_on_path()
		-- ONE normalization policy for every consumer (see split_dep_names):
		-- non-table deps degrade to nothing to resolve, and dropped entries
		-- (non-string / empty — config mistakes) surface in the unknown bucket
		-- instead of vanishing or flowing into module-name concatenation.
		local deps, invalid_entries = split_dep_names(spec.deps)
		for _, entry in ipairs(invalid_entries) do
			collector.mark_unknown(entry == "" and '""' or entry)
		end
		-- Phase 1: configure everything resolvable without the registry.
		local visited = {}
		local unresolved = {}
		local finalized = false
		for _, name in ipairs(deps) do
			-- Dedup (a duplicate would double-install); pcall isolates each dep.
			if not visited[name] then
				visited[name] = true
				-- A name the spec knows it can never resolve (e.g. a conform
				-- function-form override that yields nothing at probe time) is
				-- final here: tailored reason, no phase 2, no registry.
				local unresolvable = nil
				if spec.unresolvable_of then
					local ok, reason = pcall(spec.unresolvable_of, name)
					unresolvable = ok and str_or_nil(reason) or nil
				end
				if unresolvable then
					collector.mark(name, unresolvable)
					finalized = true
				else
					local ok, handled = pcall(configure_available, name)
					if not ok then
						collector.mark(name, error_reason(handled))
					elseif handled ~= true then
						unresolved[#unresolved + 1] = name
						session.pending[name] = true
					end
				end
			end
		end
		-- Final phase-1 marks must not wait behind installs or a stalled
		-- registry refresh elsewhere in the batch: flush them now (`emitted`
		-- dedups the later done()).
		if finalized then
			collector.done()
		end

		-- Expose anything pending to the install hand-off paths — phase-2
		-- leftovers AND parked phase-1 $PATH-branch failures (pending ⊇
		-- unresolved, so this is the single registration point).
		if next(session.pending) ~= nil then
			sessions[#sessions + 1] = session
		end

		-- Nothing left to install: Mason stays unloaded.
		if #unresolved == 0 then
			collector.done()
			return
		end

		-- Phase 2: resolve leftovers against the registry (value, nil, or lazy
		-- thunk — via session.resolve_registry; phase 1 never touches it, so a
		-- fully-provisioned subsystem with no leftovers never loads Mason),
		-- refreshing a never-bootstrapped one first.
		local registry = session.resolve_registry()
		-- The registry is loaded anyway: make sure mid-session installs hand off.
		if registry then
			M.attach_registry_events(registry)
		end
		local function finish()
			for _, name in ipairs(unresolved) do
				local ok, err = pcall(resolve_missing, name, registry)
				if not ok then
					collector.mark(name, error_reason(err))
				end
			end
			collector.done()
			-- Unknown-name removals don't pass through do_configure: sweep here
			-- so a fully-classified session doesn't linger in `sessions`.
			drop_session_if_done(session)
		end
		if registry and type(registry.refresh) == "function" and not registry_bootstrapped(registry) then
			-- A stalled refresh() never calls back: arm a REPORTING deadline. It
			-- does not cancel a late refresh — finish() still runs on completion,
			-- its re-marks absorbed by the entries-table dedup.
			local finished = false
			local function on_refreshed()
				if finished then
					return
				end
				finished = true
				finish()
			end
			vim.defer_fn(function()
				if finished then
					return
				end
				for _, name in ipairs(unresolved) do
					local reason = validate_reason(name)
					-- The generic refresh note is a placeholder: a later concrete
					-- failure (or a late unknown classification) may replace it.
					collector.mark(
						name,
						reason or "Mason registry refresh did not complete (cannot classify or auto-install)",
						reason == nil
					)
				end
				collector.done()
			end, timeout_ms)
			-- pcall guards a synchronous throw; the callback arrives in a fast event context.
			local ok = pcall(registry.refresh, function()
				if vim.in_fast_event() then
					vim.schedule(on_refreshed)
				else
					on_refreshed()
				end
			end)
			if not ok then
				on_refreshed()
			end
		elseif spec.defer_phase2 then
			-- Opt-in consumers (runtime tools, LSP) move the full registry spec
			-- decode off the lazy-load trigger's tick; their late configures
			-- have their own catch-up paths (enable() attaches open buffers,
			-- lint re-runs itself).
			vim.schedule(finish)
		else
			-- DAP configures IN phase 2, and a cmd-triggered lazy-load replays
			-- synchronously right after config: finish on this tick.
			finish()
		end
	end

	if spec.defer then
		M.ensure_mason_on_path()
		vim.schedule(function()
			run()
			synchronous = false
		end)
	else
		run()
		synchronous = false
	end
end

---Discovery-first resolution for a subsystem whose own runtime registrations
---are the ground truth (conform, nvim-lint). `probe(name)` returns:
---  * nil                   -> unknown name (typo) -> fix config.
---  * { binary = "x" }      -> the tool invokes executable "x".
---  * { binary = nil }      -> the tool resolves its own command at runtime.
---  * { unresolved = true } -> the name is real but its command can't be
---                             verified at probe time (e.g. a per-buffer
---                             function override): reported missing with a
---                             tailored reason — never a typo, never an install.
---  * { broken = "reason" } -> config exists but errors: surfaced with the
---                             reason — never typo guidance, never an install.
---Mason is only the lazy install fallback, reverse-looked-up from the binary.
---@param title string @Notification title identifying the subsystem.
---@param deps string[] @Tool names as the subsystem knows them.
---@param probe fun(name: string): { binary: string|nil, broken: string|nil, unresolved: boolean|nil, reason: string|nil }|nil
---@param configure? fun(name: string, late: boolean) @Optional: run for each available/local tool
---  (e.g. rewrite its command to an absolute path while Mason's bin dir is
---  still off $PATH).
---@param opts? { defer?: boolean } @`defer` moves the whole resolve off the
---  caller's tick (see M.resolve); the $PATH guarantee stays synchronous.
function M.resolve_runtime_tools(title, deps, probe, configure, opts)
	local cache = {}
	local function info(name)
		if cache[name] == nil then
			local ok, result = pcall(probe, name)
			if ok and type(result) == "table" then
				cache[name] = {
					known = true,
					binary = str_or_nil(result.binary),
					broken = str_or_nil(result.broken),
					unresolved = result.unresolved == true,
					-- Consumer-specific phrasing for the unresolved warning
					-- stays in the consumer's probe, not in this shared helper.
					reason = str_or_nil(result.reason),
				}
			else
				-- A probe error is treated as unknown: either way, fix the config entry.
				cache[name] = { known = false }
			end
		end
		return cache[name]
	end

	M.resolve({
		title = title,
		deps = deps,
		registry = M.default_registry,
		package_of = function(name, registry)
			local binary = info(name).binary
			if not registry or not binary then
				return nil
			end
			return package_for_binary(registry, binary)
		end,
		binaries_of = function(name)
			local binary = info(name).binary
			return binary and { binary } or {}
		end,
		-- binaries_of ignores `pkg` (one static probe name): phase 2 must not
		-- repeat phase 1's identical $PATH probe for these specs.
		static_binaries = true,
		unknown_of = function(name)
			return not info(name).known
		end,
		has_local_config = function(name)
			-- A broken config counts as local so configure below surfaces its
			-- reason; an unresolved one does NOT (nothing verifiable to trust).
			local i = info(name)
			return i.known and i.binary == nil and not i.unresolved
		end,
		unresolvable_of = function(name)
			local i = info(name)
			if i.unresolved then
				return i.reason or "config could not be verified at startup"
			end
		end,
		-- A binary-less runtime tool can't map to a package, so it self-resolves.
		local_config_mode = "resolves",
		defer_phase2 = true,
		defer = type(opts) == "table" and opts.defer == true or nil,
		configure = function(name, late)
			-- A broken config must never configure: raise its reason verbatim (it
			-- may carry the broken file's own "path:line:").
			local reason = info(name).broken
			if reason then
				M.raise_verbatim(reason)
			end
			if type(configure) == "function" then
				return configure(name, late)
			end
		end,
	})
end

-- Manual hand-off entry for installs Mason can't announce (mise/nix/npm);
-- pcall so a re-source of this module can't fail on the existing command.
pcall(vim.api.nvim_create_user_command, "ToolsRetry", function()
	M.retry_missing()
end, { desc = "Retry configuring missing tools (pick up installs done outside Mason)" })

return M

local M = {}

-- vim.lsp.config registrations from `user.configs.lsp` (name -> ordered list
-- of { cfg } merges / { replace = true, cfg } assignments): EVERY configure
-- replays them, since its repo-spec registration would otherwise force-merge
-- over the user's keys — a post-install late configure is merely the latest
-- timing this covers.
local user_lsp_configs = {}

-- Bridge set by setup(): read-triggered registration (fun(real, name)) so a
-- `user.configs.lsp` read of a not-yet-registered lsp_deps server sees the
-- post-registration view regardless of install timing.
local registration_trigger = nil
-- Bridge set by setup(): drops a server's cached probe when a user op or a
-- registration changes what the truth source resolves for it.
local server_info_invalidate = nil
-- Bridge set by setup(): the discovery pass, run AFTER `user.configs.lsp` so
-- its runtime registrations are visible to the unknown/binary classification.
local resolve_deps = nil
-- Bridge set by setup(): resolves every still-deferred per-filetype batch —
-- the parity sweep's target and a manual escape hatch.
local resolve_remaining = nil
-- User overrides run once per session (see run_user_lsp_overrides' doc):
-- a second call is refused loudly.
local overrides_ran = false
-- lspconfig server name -> Mason package name. Re-fetched while empty:
-- get_mappings() returns {} on a never-bootstrapped registry.
local lspconfig_to_package = nil
local update_clear_attached = false

---Run `user.configs.lsp` with vim.lsp.config proxied to record per-server
---registrations. Reads forward to the real table — after triggering the dep's
---real registration first, so a read-modify-write override snapshots the same
---base whether or not the server was installed yet. "*" is not recorded (core
---merges it at read time); the real table is always restored right after the
---pcall'd require (same silent-if-missing behavior as before).
---
---Supported surface for the user module: per-name operations only —
---`vim.lsp.config[name]` reads, `vim.lsp.config(name, cfg)` calls and
---`vim.lsp.config[name] = cfg` assignments (record/replay and the read
---trigger exist for exactly these). Enumeration (pairs over the proxy,
---core-private `_configs`) is out of contract: its visible set depends on
---registration order by nature.
---
---Once per session: the ops write through to the real table, so a rerun
---could not rebuild from a clean slate; changes need a restart.
function M.run_user_lsp_overrides()
	if overrides_ran then
		vim.notify(
			"user LSP overrides are applied once per session; restart Neovim to apply changes",
			vim.log.levels.WARN,
			{ title = "nvim-lspconfig" }
		)
		return
	end
	overrides_ran = true
	local real = vim.lsp.config
	-- The proxy may outlive the require below (a user module can stash the
	-- reference and read it from a deferred context): every metamethod is
	-- gated on this window so a post-restore read can never re-install the
	-- proxy as the global, and post-window ops write through without being
	-- recorded as overrides. (Deliberate consequence: server_info_invalidate
	-- no longer fires for post-window writes through a captured reference —
	-- an out-of-contract surface either way.)
	local window_open = true
	local proxy
	proxy = setmetatable({}, {
		__index = function(_, key)
			if window_open and registration_trigger and type(key) == "string" and key ~= "*" then
				-- The handler (and a function-form spec) registers through the
				-- GLOBAL vim.lsp.config: it must be the real table while the
				-- trigger runs, or the registration would be recorded as user
				-- ops / re-enter this proxy. pcall guarantees the restore.
				vim.lsp.config = real
				pcall(registration_trigger, real, key)
				vim.lsp.config = proxy
			end
			return real[key]
		end,
		__newindex = function(_, key, value)
			real[key] = value
			if window_open and type(key) == "string" and key ~= "*" then
				-- Assignment replaces the whole config: supersede earlier recordings.
				user_lsp_configs[key] = { { replace = true, cfg = value } }
				-- The op may have changed what the truth source resolves (cmd
				-- included): drop the cached probe.
				if server_info_invalidate then
					server_info_invalidate(key)
				end
			end
		end,
		__call = function(_, name, cfg)
			real(name, cfg)
			if window_open and type(name) == "string" and name ~= "*" and type(cfg) == "table" then
				local list = user_lsp_configs[name] or {}
				list[#list + 1] = { cfg = cfg }
				user_lsp_configs[name] = list
				if server_info_invalidate then
					server_info_invalidate(name)
				end
			end
		end,
	})
	vim.lsp.config = proxy
	pcall(require, "user.configs.lsp")
	vim.lsp.config = real
	window_open = false
end

---Test hook (anti-rot): recorded user-op count for a server — the override
---window's observable. No runtime reader.
---@param name string
---@return integer
function M._recorded_ops_count(name)
	return #(user_lsp_configs[name] or {})
end

-- Test hook (anti-rot): read by the phase-2 invariant pin. Reads the mapping
-- cache directly — package_of's self_resolving guard returns nil for any
-- already-configured function-cmd server (jsonls post-configure), which would
-- blind the pin in the healthy state.
M._mapped_package = function(name)
	return lspconfig_to_package and lspconfig_to_package[name] or nil
end

---The discovery pass, split out of setup(): lsp.lua runs it AFTER
---`user.configs.lsp`, so runtime registrations from the user module exist
---before the unknown/binary classification judges the deps. No-op until
---setup() has installed the pass.
function M.resolve_deps()
	if resolve_deps then
		resolve_deps()
	else
		-- Fail loudly, matching run_user_lsp_overrides' convention: a
		-- pre-setup call means every lsp_deps entry would silently stay
		-- unconfigured (pcall(LspStart) masks the aftermath).
		vim.notify(
			"mason-lspconfig setup() has not run; lsp_deps were not resolved",
			vim.log.levels.WARN,
			{ title = "nvim-lspconfig" }
		)
	end
end

---Resolve every per-filetype batch still deferred. Manual escape hatch and
---the harness hook (the in-file parity sweep calls the LOCAL directly).
function M.resolve_remaining()
	if resolve_remaining then
		resolve_remaining()
	else
		vim.notify(
			"mason-lspconfig setup() has not run; nothing to resolve",
			vim.log.levels.WARN,
			{ title = "nvim-lspconfig" }
		)
	end
end

M.setup = function()
	local settings = require("core.settings")
	local tools = require("modules.utils.tools")

	-- lsp_deps as a set: the read trigger below only acts on names this config
	-- actually manages.
	local deps_set = {}
	-- Parenthesized: split_dep_names' second return must not reach ipairs.
	for _, name in ipairs((tools.split_dep_names(settings.lsp_deps))) do
		deps_set[name] = true
	end
	-- Servers whose registration already ran (configure() or a read trigger):
	-- configure() skips re-registration, so a registration triggered before the
	-- user's ops can never be re-asserted over them later.
	local registered = {}

	---Ordered server-spec modules for a server: user override, then repo default.
	---@param name string
	---@return string[]
	local function server_modules(name)
		return { "user.configs.lsp-servers." .. name, "completion.servers." .. name }
	end

	---cmd → probeable binary: a table cmd's argv[0], nil otherwise (a function
	---cmd resolves its own launch). The ONE extraction rule for every
	---classification site in server_info/unknown_of below.
	---@param cmd any
	---@return string|nil
	local function binary_of_cmd(cmd)
		return type(cmd) == "table" and cmd[1] or nil
	end

	---THE guarded truth-source read (vim.lsp.config resolves '*', rtp lsp/
	---files and stored registrations exactly the way enable() consumes them):
	---one implementation for every consulting site. Deliberately NOT memoized —
	---unknown_of re-consults after a cached negative and server_info rebuilds
	---after invalidation, both of which need fresh reads. Per-purpose field
	---checks stay at the call sites.
	---@param name string
	---@return table|nil
	local function resolved_config(name)
		local ok, config = pcall(function()
			return vim.lsp.config[name]
		end)
		return (ok and type(config) == "table") and config or nil
	end

	-- Late parity sweep: every lsp_deps entry is classified at most this long
	-- after resolve_deps even if its filetype never opens (missing-tool
	-- warnings and installs still happen once per session, off any hot path).
	local SWEEP_DELAY_MS = tools.SWEEP_DELAY_MS -- one source; divergence rationale lives there

	vim.diagnostic.config({
		signs = true,
		underline = true,
		virtual_text = false,
		update_in_insert = false,
	})

	local opts = {
		capabilities = require("modules.utils").get_lsp_capabilities(),
	}

	---Probe and cache a server's spec once. `binary` = first table-cmd entry in
	---precedence order (user, repo, lspconfig); nil for a function/absent cmd.
	---Post-registration the resolved config's cmd wins unconditionally (a
	---registered cmd is what enable() will spawn).
	local server_info_cache = {}
	---@class mason_lspconfig.ServerInfo
	---@field has_module boolean
	---@field binary string|nil
	---@field known_lspconfig boolean
	---@field self_resolving boolean|nil @Resolved cmd is a function owned by the config: no Mason classification.
	---@field spec any @Winning local spec (user precedence, else repo default).
	---@field merge_base table|nil @Repo default table under a user TABLE override (merge-under policy).
	---@field broken_reason string|nil
	---@param name string
	---@return mason_lspconfig.ServerInfo
	local function server_info(name)
		local cached = server_info_cache[name]
		if cached then
			return cached
		end
		local info = {
			has_module = false,
			binary = nil,
			known_lspconfig = false,
			broken_reason = nil,
		}
		local modules = server_modules(name)
		-- A spec that exists but throws at load is a broken config, not a typo:
		-- `exists` keeps it out of the unknown bucket, and the reason makes
		-- mason_lsp_handler refuse to fall through past it.
		local user_ok, user_spec, user_exists, user_reason = tools.load_module_or_report(modules[1], "nvim-lspconfig")
		if user_ok then
			info.has_module = true
			if type(user_spec) == "table" then
				info.binary = binary_of_cmd(user_spec.cmd)
			end
		elseif user_exists then
			info.has_module = true
			info.broken_reason = user_reason
				or string.format("failed to load `%s` (see the earlier error notification)", modules[1])
		end
		-- Load the repo preset only when usable (no override, or as merge base under a
		-- table override): a function-form override replaces it wholesale.
		-- POLICY (unified since the discovery-first branch, including the formerly
		-- "external" servers nil_ls/nixd/shuck): a TABLE override MERGES over the
		-- repo preset ("write what you change"); full replacement is expressed as
		-- a function-form override.
		local default_loaded, default_spec = false, nil
		if not user_ok or type(user_spec) == "table" then
			local ok, spec, exists, reason = tools.load_module_or_report(modules[2], "nvim-lspconfig")
			if ok then
				info.has_module = true
				default_loaded = true
				default_spec = spec
				if info.binary == nil and type(spec) == "table" then
					info.binary = binary_of_cmd(spec.cmd)
				end
			elseif exists then
				info.has_module = true
				-- Under a valid user TABLE override a broken preset is merely the
				-- optional merge base: degrade to {} (already notified once by
				-- load_module_or_report) instead of disabling the server.
				if not user_ok and info.broken_reason == nil then
					info.broken_reason = reason
						or string.format("failed to load `%s` (see the earlier error notification)", modules[2])
				end
			end
		end
		-- Precedence, decided ONCE here (the handler consumes these fields
		-- instead of re-deriving it): user wins; a user TABLE override merges
		-- over the repo default (merge_base), any other user shape replaces it.
		if user_ok then
			info.spec = user_spec
			if type(user_spec) == "table" and type(default_spec) == "table" then
				info.merge_base = default_spec
			end
		elseif default_loaded then
			info.spec = default_spec
		end
		---The truth source: vim.lsp.config[name] resolves '*', rtp lsp/<name>.lua
		---files and stored registrations exactly the way enable() will consume
		---them; nil = no name-specific source at all (a pure '*' config cannot
		---make a name known). The per-name rtp rescan only happens for names
		---this cache hasn't answered yet — bounded by lsp_deps.
		-- (Reads go through the shared resolved_config above.)
		---Whether the recorded user ops explicitly set a cmd: the replay
		---guarantees that cmd is the enable-time winner.
		local user_sets_cmd = false
		for _, entry in ipairs(user_lsp_configs[name] or {}) do
			if type(entry.cfg) == "table" and entry.cfg.cmd ~= nil then
				user_sets_cmd = true
			end
		end
		if registered[name] or user_sets_cmd then
			-- Registered (or user-overridden cmd): the resolved config IS what
			-- enable() will spawn — it outranks the module-derived binary. A
			-- non-table cmd (function) means the config owns its own launch:
			-- flag it so Mason never classifies/installs against it.
			local config = resolved_config(name)
			if config and config.cmd ~= nil then
				info.known_lspconfig = true
				info.binary = binary_of_cmd(config.cmd)
				if type(config.cmd) ~= "table" then
					info.self_resolving = true
				end
			end
		elseif info.binary == nil or not info.has_module then
			-- Pre-registration the module spec is the better predictor of the
			-- upcoming stored registration (an lspconfig rtp default must not
			-- shadow a module's custom path); consult the truth source only for
			-- what the modules couldn't answer. Any cmd (even a function)
			-- proves the name real (keeps jsonls out of the unknown bucket).
			local config = resolved_config(name)
			if config and config.cmd ~= nil then
				info.known_lspconfig = true
				if info.binary == nil then
					info.binary = binary_of_cmd(config.cmd)
				end
			end
		end
		server_info_cache[name] = info
		return info
	end
	server_info_invalidate = function(name)
		server_info_cache[name] = nil
	end

	---Register (not enable) a server's config, reusing the spec server_info()
	---loaded; raises on a broken/misshapen spec so the resolver aggregates the
	---reason. vim.lsp.enable() runs later in configure().
	---@param lsp_name string
	local function mason_lsp_handler(lsp_name)
		local info = server_info(lsp_name)
		-- No-fall-through contract, enforced by the ONE shared implementation
		-- (tools.usable_or_raise): a broken or wrong-shaped config must never
		-- read as success — that would suppress both the warning and the
		-- install fallback. Precedence was decided by server_info
		-- (info.spec / info.merge_base).
		local spec = tools.usable_or_raise(info.spec, info.broken_reason, {
			label = "server config",
			expected = "a fun(opts) or a table",
			shapes = { ["function"] = true, table = true },
		})
		if spec == nil then
			-- Default to use factory config for server(s) that doesn't include a spec
			vim.lsp.config(lsp_name, opts)
		elseif type(spec) == "function" then
			-- Server owns its setup; it must call vim.lsp.config() itself (see
			-- clangd.lua for an example).
			spec(opts)
		else
			vim.lsp.config(lsp_name, vim.tbl_deep_extend("force", opts, info.merge_base or {}, spec))
		end
	end

	local function package_of(name)
		-- A registered/user function cmd owns its own launch: never classify
		-- it against a Mason package (no install fallback for it).
		if server_info(name).self_resolving then
			return nil
		end
		if lspconfig_to_package == nil or next(lspconfig_to_package) == nil then
			-- Lazy fetch: requiring mason-lspconfig here (absent/broken module
			-- degrades to $PATH-only classification — empty map → nil → the
			-- plain missing/unknown report, not a raw Lua error into the
			-- resolver's error-mark) goes through lazy.nvim's module loader,
			-- which loads mason-core (and thus mason.setup) first, then runs
			-- the spec config (mason-lspconfig-setup) exactly once. The empty
			-- map keeps the re-fetch-while-empty semantics: a persistently
			-- drifted call re-degrades per lookup instead of freezing a bad
			-- shape.
			-- TRUNCATION WARNING: pcall(...) as a non-final operand of and/or
			-- is adjusted to ONE value — keep this a two-statement fetch, not
			-- `ok_mod and pcall(f) or false, nil` (that assigns mappings = nil
			-- ALWAYS and permanently freezes the cache at {}).
			local ok_mod, mlsp = pcall(require, "mason-lspconfig")
			local ok, mappings = false, nil
			if ok_mod then
				ok, mappings = pcall(mlsp.get_mappings)
			end
			lspconfig_to_package = (ok and type(mappings) == "table" and type(mappings.lspconfig_to_package) == "table")
					and mappings.lspconfig_to_package
				or {}
			-- The mapping derives from the registry specs: a registry update
			-- must not leave the first non-empty snapshot frozen. SYNCHRONOUS
			-- clear on purpose — the emit-order rationale lives at tools.lua's
			-- update:success handler (the one place that fact is argued).
			-- Attached lazily, right here: the cache this guards cannot be
			-- non-empty before this branch runs (it fills three lines up).
			-- Runs on FAILED fetches too — default_registry() may then load
			-- mason.nvim itself; this branch is phase-2/event-only, where
			-- that load is permitted. Once attached, never re-tried; pcall
			-- guards mason-registry API drift. If the registry never loads
			-- through this file, the cache stays nil/{} and there is nothing
			-- to invalidate (re-fetch-while-empty covers it).
			if not update_clear_attached then
				local mason_registry = tools.default_registry()
				if mason_registry and type(mason_registry.on) == "function" then
					update_clear_attached = pcall(function()
						mason_registry:on("update:success", function()
							lspconfig_to_package = nil
						end)
					end)
				end
			end
		end
		return lspconfig_to_package[name]
	end

	---Use a manual/built-in spec as fallback only when its binary can't be probed
	---statically (function/absent `cmd`); with a known binary the $PATH check decides.
	---@param name string
	---@return boolean
	local function has_local_config(name)
		local info = server_info(name)
		return info.binary == nil and (info.has_module or info.known_lspconfig)
	end

	---Typo/outdated name vs valid-but-uninstalled: a Mason mapping, a repo/user server
	---module, or a built-in lspconfig config all mean the name is real.
	---@param name string
	---@return boolean
	local function unknown_of(name)
		if package_of(name) then
			return false
		end
		local info = server_info(name)
		if info.has_module or info.known_lspconfig then
			return false
		end
		-- A runtime registration may have landed after the probe cached its
		-- negative (the user read the name first, then wrote a cmd): re-consult
		-- the truth source before the typo verdict, upgrading the cache in place.
		local config = resolved_config(name)
		if config and config.cmd ~= nil then
			info.known_lspconfig = true
			if info.binary == nil then
				info.binary = binary_of_cmd(config.cmd)
			end
			return false
		end
		return true
	end

	---Register a server (unless a read trigger already did), then enable it (a
	---bare Mason `cmd` spawns fine: the resolver put Mason's bin dir on $PATH).
	local function configure(name)
		if not registered[name] then
			mason_lsp_handler(name)
			registered[name] = true
			-- The probe cached pre-registration state: rebuild so later readers
			-- (group-1 retry/event matchers) see the resolved cmd.
			server_info_cache[name] = nil
		end
		-- Replay recorded `user.configs.lsp` registrations on top: discovery
		-- runs AFTER the user module (lsp.lua orders setup → overrides →
		-- resolve), so the repo-spec registration above just force-merged over
		-- any write-only override's keys — this replay restores them on every
		-- configure. Only the read-triggered path (registration before
		-- recording) makes it a natural no-op.
		for _, entry in ipairs(user_lsp_configs[name] or {}) do
			if entry.replace then
				vim.lsp.config[name] = entry.cfg
			else
				vim.lsp.config(name, entry.cfg)
			end
		end
		vim.lsp.enable(name)
	end

	-- Read-triggered registration (transactional). Any spec form is covered by
	-- simply running the real registration: the function-form contract is
	-- "only registers via vim.lsp.config()" (see clangd.lua), so running it
	-- early is registration, not behavior. A failing registration is rolled
	-- back so the read never leaks a partial config; `registered` stays false
	-- and the resolver's configure() path reports the raise as usual.
	registration_trigger = function(real, name)
		if not deps_set[name] or registered[name] then
			return
		end
		-- Core keeps stored registrations in `vim.lsp.config._configs`; without
		-- it (API drift) the trigger degrades to the status-quo read — no
		-- half-transaction.
		local store = rawget(real, "_configs")
		if type(store) ~= "table" then
			return
		end
		-- vim.deepcopy raises on userdata values; without a snapshot there is
		-- no rollback guarantee, so degrade to the status-quo read exactly
		-- like the _configs drift guard above. (Hardening: the sole caller
		-- already pcalls the trigger, but the swallow made the abort silent.)
		local copy_ok, before = pcall(vim.deepcopy, store[name])
		if not copy_ok then
			return
		end
		if pcall(mason_lsp_handler, name) then
			registered[name] = true
			-- The handler's own server_info ran pre-registration (a function-form
			-- spec registers its cmd mid-trigger, bypassing the proxy hooks):
			-- rebuild so the probe reflects the resolved, registered cmd.
			server_info_cache[name] = nil
		else
			store[name] = before
		end
	end

	---One resolve pass over a batch of deps. The collector aggregates by
	---title across batches; each batch gets its own session/pending record
	---(retry_pending walks all of them).
	---@param deps any[]
	local function resolve_batch(deps)
		tools.resolve({
			title = "LSP",
			deps = deps,
			-- A thunk: phase 1 never touches it; phase 2 resolves it via
			-- session.resolve_registry only once leftovers exist.
			registry = tools.default_registry,
			package_of = package_of,
			binaries_of = function(name, pkg)
				local info = server_info(name)
				if info.binary then
					return { info.binary }
				end
				-- A registered/user function cmd resolves its own launch: probing
				-- Mason bins would misread it as installable/missing.
				if info.self_resolving then
					return {}
				end
				-- Function-cmd MODULE server (jsonls): probe the package's declared
				-- bins so a system copy is found instead of installing a duplicate.
				if pkg ~= nil then
					return tools.package_binaries(pkg, name)
				end
				return {}
			end,
			unknown_of = unknown_of,
			has_local_config = has_local_config,
			configure = configure,
			-- Phase 2 (registry classification: full mappings decode + package
			-- hydration) moves off the BufReadPre tick. Safe because a late
			-- configure's vim.lsp.enable() attaches already-open matching
			-- buffers (documented semantics — :h vim.lsp.enable()), so the one
			-- same-tick beneficiary — a Mason-installed server whose binary
			-- name differs from the probe — still reaches the triggering
			-- buffer.
			defer_phase2 = true,
		})
	end

	-- Per-filetype deferral state, (re)built by each resolve_deps run. One static
	-- shape plus one grow-only set — every other question is derived, so there is
	-- no lockstep to drift (the old third table, bucketed_fts, existed only
	-- because consuming a bucket destroyed the "was ever bucketed" fact; a static
	-- map's keys keep it by construction):
	--   bucket_by_ft  ft   -> the GENERATION-STATIC name list deferred under it
	--                         (never mutated after the build; keys double as the
	--                         re-fire/N4 tombstone).
	--   handed_off    name -> already handed to the resolver (grow-only; a server
	--                         listed under several filetypes — gopls: go/gomod/
	--                         gowork/gotmpl — resolves ONCE).
	--   undeferred    countdown of UNIQUE deferred names not yet handed off; 0 is
	--                         the augroup-teardown gate (name-accurate, unlike the
	--                         old bucket-emptiness gate — see the teardown note).
	-- A resolve_batch throw can leave the augroup inert: thrown on a later
	-- FileType fire, the (already scheduled) sweep still tears it down; thrown
	-- during the initial buffer replay it can linger until the next
	-- resolve_deps' clear=true. Benign either way — the callback no-ops at the
	-- undeferred guard.
	local bucket_by_ft = {}
	local handed_off = {}
	local undeferred = 0
	local perft_group = nil

	---Hand a filetype's still-unresolved names to the resolver. No-op (empty
	---batch) for a consumed or unknown ft — the caller never needs to know which.
	---@param ft string
	local function resolve_ft(ft)
		local bucket = bucket_by_ft[ft]
		if not bucket then
			return
		end
		local batch = {}
		for _, name in ipairs(bucket) do
			if not handed_off[name] then
				handed_off[name] = true
				undeferred = undeferred - 1
				batch[#batch + 1] = name
			end
		end
		if #batch > 0 then
			resolve_batch(batch)
		end
		-- Teardown when no NAME remains unresolved: once every deferred server is
		-- handed off, later FileType fires have nothing to do even for buckets
		-- whose own ft never fired (their members resolved via sibling fts).
		if undeferred <= 0 and perft_group then
			pcall(vim.api.nvim_del_augroup_by_id, perft_group)
			perft_group = nil
		end
	end

	resolve_remaining = function()
		-- Drain through resolve_ft — the ONE copy of the hand-off invariant
		-- (handed_off gate, undeferred countdown, augroup teardown at zero).
		-- Per-ft batches are the designed-for shape: the collector aggregates
		-- one warning per title across batches, and retry_pending walks every
		-- session. Mid-drain throw: marking-before-batch ordering is preserved,
		-- so a throwing batch still leaves OTHER fts deferred with a live
		-- FileType recovery path instead of draining them into the throwing
		-- batch — their buckets are static and their unhanded names still
		-- route; the next resolve_deps' clear = true recreates the group.
		for _, ft in ipairs(vim.tbl_keys(bucket_by_ft)) do
			resolve_ft(ft)
		end
	end

	---Route a filetype event to the right deferred resolution. The bucket only
	---controls WHEN a server loads (enable() attaches by the module's real
	---filetypes), so this only affects load timing, never attach correctness.
	---@param buf integer
	---@param ft string
	local function on_filetype(buf, ft)
		if ft == "" or undeferred <= 0 then
			return
		end
		if bucket_by_ft[ft] then
			-- 1. listed ft: targeted resolve; a re-fired ALREADY-consumed listed ft
			-- takes this same path and no-ops on the empty batch — the static key
			-- IS the old bucketed_fts tombstone (reopening a resolved `.lua`/`.go`
			-- must never fall through and drain the still-deferred yaml servers).
			resolve_ft(ft)
			return
		end
		local base = ft:match("^([^.]+)%.")
		if base and bucket_by_ft[base] then
			-- 2. dotted variant (yaml.github → yaml): resolve the base bucket; a
			-- consumed base no-ops the same way (the old N4 branch). ASSUMPTION
			-- unchanged from A2: the server owning a dotted variant is in its
			-- base's bucket (true for every current dep); a future foo.bar-without-
			-- foo server waits for the sweep — bounded, still resolves.
			resolve_ft(base)
			return
		end
		-- 3. An unlisted REAL-file filetype: a repo module may declare it beyond
		-- lspconfig's defaults (shuck→ksh, harper_ls→text) and we cannot know which
		-- without loading, so drain the rest now — the 120s sweep, triggered early.
		-- buftype guard keeps help/quickfix/dashboard/terminal/prompt buffers from
		-- tripping it; a real file whose ft has no server just pays one early drain
		-- (identical work the sweep would do), one-shot. Residual, bounded and
		-- one-shot (never worse than the pre-refactor eager load): an unlisted
		-- real-file ft (a module-added plain ft like text/ksh, or a serverless ft
		-- like csv) drains all remaining deferred servers early.
		if vim.bo[buf].buftype == "" then
			resolve_remaining()
		end
	end

	-- The discovery pass itself runs via M.resolve_deps() AFTER
	-- run_user_lsp_overrides() (see lsp.lua): user runtime registrations must
	-- exist before the unknown/binary classification. It partitions the RAW
	-- dep list: invalid entries stay in the immediate batch verbatim (the
	-- resolver's own re-scan reports them); user-overridden names (either
	-- hook) keep today's load-tick semantics; only names whose filetypes come
	-- from NON-user sources (rtp lsp/ files, default registrations) defer to
	-- their filetype's first buffer, resolved by on_filetype, with the sweep as
	-- the parity backstop.
	resolve_deps = function()
		-- Superseded sessions from a previous run of this consumer must not be retried (re-source guard).
		tools.drop_sessions("LSP")
		local immediate = {}
		bucket_by_ft, handed_off, undeferred = {}, {}, 0
		-- Re-source/generation token for the sweep timer, same pattern as
		-- nvim-lint's parity sweep (vim.g survives both re-source flavors): a
		-- stale timer from a previous run — or a previous module instance —
		-- must not drain rebuilt buckets at the wrong deadline.
		local gen = (vim.g._masonlsp_resolve_gen or 0) + 1
		vim.g._masonlsp_resolve_gen = gen
		-- ONE container-shape policy, shared with deps_set at setup top
		-- (split_dep_names: bare string = singleton dep) — a divergent
		-- drop-whole here let a string lsp_deps register via the read trigger
		-- yet never resolve, enable, or warn.
		local valid, invalid = tools.split_dep_names(settings.lsp_deps)
		local seen = {}
		for _, entry in ipairs(valid) do
			local fts = nil
			local user_hooked = tools.module_path(server_modules(entry)[1]) ~= nil
				or (user_lsp_configs[entry] and #user_lsp_configs[entry] > 0)
			if not user_hooked then
				local config = resolved_config(entry)
				if config and type(config.filetypes) == "table" then
					fts = config.filetypes
				end
			end
			local placed = false
			if fts then
				for _, ft in ipairs(fts) do
					if type(ft) == "string" and ft ~= "" then
						local bucket = bucket_by_ft[ft] or {}
						bucket[#bucket + 1] = entry
						bucket_by_ft[ft] = bucket
						if not seen[entry] then
							seen[entry] = true
							undeferred = undeferred + 1
						end
						placed = true
					end
				end
			end
			if not placed then
				immediate[#immediate + 1] = entry
			end
		end
		-- Entries split_dep_names drops (non-string / empty) are config
		-- mistakes: forward them raw so the resolver's own re-scan reports
		-- them in the unknown bucket — same pattern as nvim-lint.
		vim.list_extend(immediate, invalid)

		-- Immediate batch first: same-tick semantics identical to the old
		-- whole-list resolve for everything that must not defer.
		if #immediate > 0 then
			resolve_batch(immediate)
		end

		if undeferred > 0 then
			perft_group = vim.api.nvim_create_augroup("MasonLspPerFtResolve", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				group = perft_group,
				pattern = "*",
				callback = function(args)
					on_filetype(args.buf, args.match)
				end,
				desc = "lsp: resolve this filetype's language servers",
			})
			-- Already-loaded buffers (including the one whose BufReadPre
			-- triggered this whole config, if its FileType already fired):
			-- resolve their filetypes on this same tick.
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(buf) then
					on_filetype(buf, vim.bo[buf].filetype)
				end
			end
			if undeferred > 0 then
				vim.defer_fn(function()
					if vim.g._masonlsp_resolve_gen == gen then
						resolve_remaining()
					end
				end, SWEEP_DELAY_MS)
			end
		end
	end
end

return M

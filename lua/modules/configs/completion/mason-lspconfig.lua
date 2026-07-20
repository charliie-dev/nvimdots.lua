local M = {}

-- vim.lsp.config registrations from `user.configs.lsp` (name -> ordered list
-- of { cfg } merges / { replace = true, cfg } assignments): a POST-INSTALL
-- late configure replays them, since its repo-spec registration would
-- otherwise force-merge over the user's keys (install-timing-dependent).
local user_lsp_configs = {}

---Run `user.configs.lsp` with vim.lsp.config proxied to record per-server
---registrations. Reads forward to the real table; "*" is not recorded (core
---merges it at read time); the real table is always restored right after the
---pcall'd require (same silent-if-missing behavior as before).
function M.run_user_lsp_overrides()
	local real = vim.lsp.config
	vim.lsp.config = setmetatable({}, {
		__index = function(_, key)
			return real[key]
		end,
		__newindex = function(_, key, value)
			real[key] = value
			if type(key) == "string" and key ~= "*" then
				-- Assignment replaces the whole config: supersede earlier recordings.
				user_lsp_configs[key] = { { replace = true, cfg = value } }
			end
		end,
		__call = function(_, name, cfg)
			real(name, cfg)
			if type(name) == "string" and name ~= "*" and type(cfg) == "table" then
				local list = user_lsp_configs[name] or {}
				list[#list + 1] = { cfg = cfg }
				user_lsp_configs[name] = list
			end
		end,
	})
	pcall(require, "user.configs.lsp")
	vim.lsp.config = real
end

M.setup = function()
	local settings = require("core.settings")
	-- Mason is an optional installer backend: guard its requires so a Mason-less
	-- setup still resolves servers from $PATH instead of hard-erroring here.
	local has_registry, mason_registry = pcall(require, "mason-registry")
	local has_mlsp, mason_lspconfig = pcall(require, "mason-lspconfig")
	local mason_ok = has_registry and has_mlsp
	local tools = require("modules.utils.tools")

	---Ordered server-spec modules for a server: user override, then repo default.
	---@param name string
	---@return string[]
	local function server_modules(name)
		return { "user.configs.lsp-servers." .. name, "completion.servers." .. name }
	end

	-- name -> lsp/<name>.lua paths in rtp order, built by ONE glob: reading
	-- vim.lsp.config[name] for a not-yet-enabled server rescans the rtp per name.
	local lsp_runtime_files = nil
	---@param name string
	---@return string[]|nil
	local function lsp_files_of(name)
		if lsp_runtime_files == nil then
			lsp_runtime_files = {}
			for _, path in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
				-- Single segment only: a nested lsp/<dir>/<file>.lua is not a server.
				local server = path:match("[/\\]lsp[/\\]([^/\\]+)%.lua$")
				if server then
					local files = lsp_runtime_files[server]
					if not files then
						files = {}
						lsp_runtime_files[server] = files
					end
					files[#files + 1] = path
				end
			end
		end
		return lsp_runtime_files[name]
	end

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
	local server_info_cache = {}
	---@class mason_lspconfig.ServerInfo
	---@field has_module boolean
	---@field binary string|nil
	---@field known_lspconfig boolean
	---@field user_loaded boolean
	---@field user_spec any
	---@field default_loaded boolean
	---@field default_spec any
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
			user_loaded = false,
			user_spec = nil,
			default_loaded = false,
			default_spec = nil,
			broken_reason = nil,
		}
		local modules = server_modules(name)
		-- A spec that exists but throws at load is a broken config, not a typo:
		-- `exists` keeps it out of the unknown bucket, and the reason makes
		-- mason_lsp_handler refuse to fall through past it.
		local user_ok, user_spec, user_exists, user_reason = tools.load_module_or_report(modules[1], "nvim-lspconfig")
		if user_ok then
			info.has_module = true
			info.user_loaded = true
			info.user_spec = user_spec
			if type(user_spec) == "table" and type(user_spec.cmd) == "table" then
				info.binary = user_spec.cmd[1]
			end
		elseif user_exists then
			info.has_module = true
			info.broken_reason = user_reason
				or string.format("failed to load `%s` (see the earlier error notification)", modules[1])
		end
		-- Load the repo preset only when usable (no override, or as merge base under a
		-- table override): a function-form override replaces it wholesale.
		if not user_ok or type(user_spec) == "table" then
			local ok, spec, exists, reason = tools.load_module_or_report(modules[2], "nvim-lspconfig")
			if ok then
				info.has_module = true
				info.default_loaded = true
				info.default_spec = spec
				if info.binary == nil and type(spec) == "table" and type(spec.cmd) == "table" then
					info.binary = spec.cmd[1]
				end
			elseif exists then
				info.has_module = true
				-- Under a valid user TABLE override a broken preset is merely the
				-- optional merge base: degrade to {} (already notified once by
				-- load_module_or_report) instead of disabling the server.
				if not info.user_loaded and info.broken_reason == nil then
					info.broken_reason = reason
						or string.format("failed to load `%s` (see the earlier error notification)", modules[2])
				end
			end
		end
		-- nvim-lspconfig's built-in config: a table cmd yields the launch binary;
		-- any cmd (even a function) proves the name real (keeps jsonls out of the
		-- unknown bucket). Read only when it can still change the outcome.
		if info.binary == nil or not info.has_module then
			-- Mirror vim.lsp.config's file resolution (later rtp files win) from
			-- the pre-globbed map instead of its per-name rescan. `*` defaults and
			-- pure-runtime registrations are not merged — this only feeds the
			-- binary probe; registration still reads vim.lsp.config[name].
			local files = lsp_files_of(name)
			if files then
				local merged = {}
				for _, path in ipairs(files) do
					local ok, chunk = pcall(loadfile, path)
					if ok and chunk then
						local ok_run, config = pcall(chunk)
						if ok_run and type(config) == "table" then
							merged = vim.tbl_deep_extend("force", merged, config)
						end
					end
				end
				if merged.cmd ~= nil then
					info.known_lspconfig = true
					if info.binary == nil and type(merged.cmd) == "table" then
						info.binary = merged.cmd[1]
					end
				end
			elseif not info.has_module then
				-- Last chance before the typo bucket: a pure-runtime registration is
				-- looked up only for names nothing else proved real, so the per-name
				-- rescan stays normally zero.
				local ok, config = pcall(function()
					return vim.lsp.config[name]
				end)
				if ok and type(config) == "table" and config.cmd ~= nil then
					info.known_lspconfig = true
					if info.binary == nil and type(config.cmd) == "table" then
						info.binary = config.cmd[1]
					end
				end
			end
		end
		server_info_cache[name] = info
		return info
	end

	---Register (not enable) a server's config, reusing the spec server_info()
	---loaded; raises on a broken/misshapen spec so the resolver aggregates the
	---reason. vim.lsp.enable() runs later in configure().
	---@param lsp_name string
	local function mason_lsp_handler(lsp_name)
		local info = server_info(lsp_name)
		-- A broken config must not fall through to a lower-precedence spec or
		-- the factory config: that would read as success and suppress both the
		-- warning and the install fallback.
		if info.broken_reason then
			tools.raise_verbatim(info.broken_reason)
		end
		local ok, custom_handler = info.user_loaded, info.user_spec
		local default_handler = info.default_spec
		-- Use preset if there is no user definition
		if not ok then
			ok, custom_handler = info.default_loaded, info.default_spec
		end

		if not ok then
			-- Default to use factory config for server(s) that doesn't include a spec
			vim.lsp.config(lsp_name, opts)
		elseif type(custom_handler) == "function" then
			-- Server owns its setup; it must call vim.lsp.config() itself (see
			-- clangd.lua for an example).
			custom_handler(opts)
		elseif type(custom_handler) == "table" then
			vim.lsp.config(
				lsp_name,
				vim.tbl_deep_extend(
					"force",
					opts,
					type(default_handler) == "table" and default_handler or {},
					custom_handler
				)
			)
		else
			tools.raise_verbatim(
				string.format("server config must return a fun(opts) or a table (got `%s`)", type(custom_handler))
			)
		end
	end

	if mason_ok then
		-- lspconfig integration only; installs are driven by the shared resolver,
		-- not gated on Mason's installed set.
		require("modules.utils").load_plugin("mason-lspconfig", {
			ensure_installed = {},
			-- Skip auto enable because we are loading language servers lazily
			automatic_enable = false,
		})
	end

	-- lspconfig server name -> Mason package name. Re-fetched while empty:
	-- get_mappings() returns {} on a never-bootstrapped registry.
	local lspconfig_to_package = nil
	local function package_of(name)
		if not mason_ok then
			return nil
		end
		if lspconfig_to_package == nil or next(lspconfig_to_package) == nil then
			local mappings = mason_lspconfig.get_mappings()
			lspconfig_to_package = (mappings and mappings.lspconfig_to_package) or {}
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
		return not info.has_module and not info.known_lspconfig
	end

	---Register a server, then enable it (a bare Mason `cmd` spawns fine: the
	---resolver put Mason's bin dir on $PATH).
	local function configure(name)
		mason_lsp_handler(name)
		-- Replay recorded `user.configs.lsp` registrations on top: a post-install
		-- configure runs after that module did, and the repo spec would otherwise
		-- force-merge over the user's keys. Synchronous configures precede the
		-- user module, so the replay is a natural no-op there.
		for _, entry in ipairs(user_lsp_configs[name] or {}) do
			if entry.replace then
				vim.lsp.config[name] = entry.cfg
			else
				vim.lsp.config(name, entry.cfg)
			end
		end
		vim.lsp.enable(name)
	end

	tools.resolve({
		title = "LSP",
		deps = settings.lsp_deps,
		-- A value, not a thunk: mason-registry was already required at setup top.
		registry = mason_ok and mason_registry or nil,
		package_of = package_of,
		binaries_of = function(name, pkg)
			local binary = server_info(name).binary
			if binary then
				return { binary }
			end
			-- Function-cmd server (jsonls): probe the package's declared bins so a
			-- system copy is found instead of installing a duplicate.
			if pkg ~= nil then
				return tools.package_binaries(pkg, name)
			end
			return {}
		end,
		unknown_of = unknown_of,
		has_local_config = has_local_config,
		configure = configure,
	})
end

return M

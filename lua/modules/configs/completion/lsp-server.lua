local M = {}
local registered = {}
local enabled = {}

---@class LspDefinitions
---@field user_ok boolean
---@field user any
---@field default_ok boolean
---@field default any
---@field user_error string?
---@field default_error string?

---@type table<string, LspDefinitions>
local definition_cache = {}

---@alias LspEntry string|{ name: string, command: string }

---@param entry LspEntry
---@return string
local function entry_name(entry)
	if type(entry) == "string" then
		assert(entry ~= "", "LSP entry name must not be empty")
		return entry
	end
	assert(type(entry) == "table", "LSP entry must be a string or table")
	assert(type(entry.name) == "string" and entry.name ~= "", "LSP table entry requires a non-empty name")
	assert(type(entry.command) == "string" and entry.command ~= "", "LSP table entry requires a non-empty command")
	return entry.name
end

---@param module string
---@return boolean present
---@return any value
---@return string? load_error
local function optional_module(module)
	local ok, value = pcall(require, module)
	if ok then
		return true, value, nil
	end
	local load_error = tostring(value)
	if load_error:find("module '" .. module .. "' not found:", 1, true) then
		return false, nil, nil
	end
	return true, nil, load_error
end

---@param name string
---@return LspDefinitions
local function get_definitions(name)
	local cached = definition_cache[name]
	if not cached then
		local user_ok, user, user_error = optional_module("user.configs.lsp-servers." .. name)
		local default_ok, default, default_error = optional_module("completion.servers." .. name)
		cached = {
			user_ok = user_ok,
			user = user,
			default_ok = default_ok,
			default = default,
			user_error = user_error,
			default_error = default_error,
		}
		definition_cache[name] = cached
	end
	return cached
end

---@param definitions LspDefinitions
---@return string?
local function relevant_load_error(definitions)
	if definitions.user_error then
		return definitions.user_error
	end
	if definitions.default_error and not (definitions.user_ok and type(definitions.user) == "function") then
		return definitions.default_error
	end
end

---@param base table
---@param definitions LspDefinitions
---@return table
local function merged_options(base, definitions)
	return vim.tbl_deep_extend(
		"force",
		base,
		type(definitions.default) == "table" and definitions.default or {},
		type(definitions.user) == "table" and definitions.user or {}
	)
end

---@return vim.lsp.Config
local function base_options()
	return {
		capabilities = require("modules.utils").get_lsp_capabilities(),
	}
end

---@param name string
---@return vim.lsp.Config?
local function materialized_config(name)
	local ok, config = pcall(function()
		return vim.lsp.config[name]
	end)
	if ok and type(config) == "table" then
		return config
	end
end

---@param cmd any
---@return string?
local function command_name(cmd)
	if type(cmd) == "string" then
		return cmd
	end
	if type(cmd) == "table" and type(cmd[1]) == "string" then
		return cmd[1]
	end
end

---@param entry LspEntry
---@return string?
local function command(entry)
	local server_name = entry_name(entry)
	local config = materialized_config(server_name)
	if config and config.cmd ~= nil then
		return command_name(config.cmd) or (type(entry) == "table" and entry.command or nil)
	end
	if type(entry) == "table" then
		return entry.command
	end

	local definitions = get_definitions(server_name)
	if relevant_load_error(definitions) then
		return nil
	end
	return command_name(merged_options({}, definitions).cmd)
end

---@param entry LspEntry
---@return boolean
function M.is_executable(entry)
	local executable = command(entry)
	return executable ~= nil and vim.fn.executable(executable) == 1
end

---@param entry LspEntry
---@return boolean registered_now
function M.register(entry)
	local server_name = entry_name(entry)
	if registered[server_name] then
		return false
	end

	-- Materialize nvim-lspconfig defaults before applying repository overrides.
	materialized_config(server_name)
	local definitions = get_definitions(server_name)
	local load_error = relevant_load_error(definitions)
	if load_error then
		vim.notify(
			string.format("Failed to load LSP definition for [%s]: %s", server_name, load_error),
			vim.log.levels.ERROR,
			{ title = "nvim-lspconfig" }
		)
		return false
	end
	local handler
	if definitions.user_ok then
		handler = definitions.user
	else
		handler = definitions.default
	end
	local defaults = base_options()

	if server_name == "rust_analyzer" then
		if definitions.default_ok then
			vim.notify(
				"`rust_analyzer` is configured independently via `mrcjkb/rustaceanvim`; remove its completion/servers entry",
				vim.log.levels.WARN,
				{ title = "nvim-lspconfig" }
			)
		end
		return false
	end

	if not definitions.user_ok and not definitions.default_ok then
		vim.lsp.config(server_name, defaults)
	elseif type(handler) == "function" then
		handler(defaults)
	elseif type(handler) == "table" then
		vim.lsp.config(server_name, merged_options(defaults, definitions))
	else
		vim.notify(
			string.format(
				"Failed to register [%s]. Server definition must return a function or table (got '%s')",
				server_name,
				type(handler)
			),
			vim.log.levels.ERROR,
			{ title = "nvim-lspconfig" }
		)
		return false
	end

	registered[server_name] = true
	return true
end

---@param entry LspEntry
---@return boolean enabled_now
function M.enable(entry)
	local server_name = entry_name(entry)
	if enabled[server_name] or not M.is_executable(entry) then
		return false
	end
	if not registered[server_name] then
		M.register(entry)
	end
	if not registered[server_name] then
		return false
	end
	vim.lsp.enable(server_name)
	enabled[server_name] = true
	return true
end

---@param entry LspEntry
---@return boolean enabled_now
function M.setup(entry)
	M.register(entry)
	return M.enable(entry)
end

return M

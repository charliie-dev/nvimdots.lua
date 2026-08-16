local M = {}
local registered = {}
local enabled = {}

---@alias LspEntry string|{ name: string, command: string }

---@param entry LspEntry
---@return string
local function entry_name(entry)
	return type(entry) == "table" and entry.name or entry
end

---@param name string
---@return boolean user_ok
---@return any user
---@return boolean default_ok
---@return any default
local function definitions(name)
	local user_ok, user = pcall(require, "user.configs.lsp-servers." .. name)
	local default_ok, default = pcall(require, "completion.servers." .. name)
	return user_ok, user, default_ok, default
end

---@return vim.lsp.Config
local function base_options()
	return {
		capabilities = require("modules.utils").get_lsp_capabilities(),
	}
end

---@param cmd any
---@return string?
local function command_name(cmd)
	if type(cmd) == "string" then
		return cmd
	end
	return type(cmd) == "table" and type(cmd[1]) == "string" and cmd[1] or nil
end

---@param entry LspEntry
---@return string?
local function command(entry)
	local server_name = entry_name(entry)
	local ok, config = pcall(function()
		return vim.lsp.config[server_name]
	end)
	if ok and type(config) == "table" and config.cmd ~= nil then
		return command_name(config.cmd) or (type(entry) == "table" and entry.command or nil)
	end
	if type(entry) == "table" then
		return entry.command
	end

	local user_ok, user, default_ok, default = definitions(server_name)
	local opts = vim.tbl_deep_extend(
		"force",
		{},
		type(default) == "table" and default_ok and default or {},
		type(user) == "table" and user_ok and user or {}
	)
	return command_name(opts.cmd)
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

	local user_ok, user, default_ok, default = definitions(server_name)
	local handler = user_ok and user or default
	local defaults = base_options()

	if server_name == "rust_analyzer" then
		if default_ok then
			vim.notify(
				"`rust_analyzer` is configured independently via `mrcjkb/rustaceanvim`; remove its completion/servers entry",
				vim.log.levels.WARN,
				{ title = "nvim-lspconfig" }
			)
		end
		return false
	end

	if not user_ok and not default_ok then
		vim.lsp.config(server_name, defaults)
	elseif type(handler) == "function" then
		handler(defaults)
	elseif type(handler) == "table" then
		vim.lsp.config(
			server_name,
			vim.tbl_deep_extend(
				"force",
				defaults,
				type(default) == "table" and default or {},
				type(user) == "table" and user or {}
			)
		)
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

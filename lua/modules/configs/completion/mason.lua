local M = {}

M.setup = function()
	local icons = {
		ui = require("modules.utils.icons").get("ui", true),
		misc = require("modules.utils.icons").get("misc", true),
	}

	require("modules.utils").load_plugin("mason", {
		ui = {
			border = "single",
			icons = {
				package_pending = icons.ui.Modified_alt,
				package_installed = icons.ui.Check,
				package_uninstalled = icons.misc.Ghost,
			},
			keymaps = {
				toggle_server_expand = "<CR>",
				install_server = "i",
				update_server = "u",
				check_server_version = "c",
				update_all_servers = "U",
				check_outdated_servers = "C",
				uninstall_server = "X",
				cancel_installation = "<C-c>",
			},
		},
	})

	-- Ensure formatters and linters are installed (only if mason loaded)
	local ok, registry = pcall(require, "mason-registry")
	if not ok then
		return
	end

	local settings = require("core.settings")
	local ensure_installed = vim.list_extend(vim.deepcopy(settings.formatter_deps), settings.linter_deps)

	for _, pkg_name in ipairs(ensure_installed) do
		local pkg_ok, pkg = pcall(registry.get_package, pkg_name)
		if pkg_ok and not pkg:is_installed() then
			pkg:install()
		end
	end
end

return M

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

	-- Formatter/linter resolution lives in conform.lua and nvim-lint.lua (against their
	-- own registrations); Mason here is UI-only / lazy install fallback.

	-- A user-driven install (:MasonInstall / the :Mason UI) must finish any
	-- pending resolver hand-off even when no resolver ever loaded the registry.
	local ok, registry = pcall(require, "mason-registry")
	if ok then
		require("modules.utils.tools").attach_registry_events(registry)
	end
end

return M

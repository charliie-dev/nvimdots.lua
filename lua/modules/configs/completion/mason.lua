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

	-- Ensure formatters and linters are available (only if mason loaded)
	local ok, registry = pcall(require, "mason-registry")
	if not ok then
		return
	end

	local settings = require("core.settings")
	local tools = require("modules.utils.tools")
	local ensure_installed = vim.list_extend(vim.deepcopy(settings.formatter_deps), settings.linter_deps)

	-- Discovery-first: only install what isn't already on $PATH, so systems that
	-- provide their own tools (NixOS/BSD/...) aren't nagged every startup. What
	-- Mason genuinely can't provide is collected into a single warning.
	local collector = tools.missing_collector("Mason")

	for _, pkg_name in ipairs(ensure_installed) do
		local pkg_ok, pkg = pcall(registry.get_package, pkg_name)
		if not pkg_ok then
			-- No such Mason package (typo / removed): Mason can't provide it and the
			-- package name isn't a reliable executable to probe. Surface it as an
			-- unknown name so the warning points at the config, not a manual install.
			collector.mark_unknown(pkg_name)
		else
			local binaries = tools.package_binaries(pkg, pkg_name)
			if not (pkg:is_installed() or tools.any_executable(binaries)) then
				collector.track(pkg, pkg_name, function()
					return pkg:is_installed() or tools.any_executable(binaries)
				end)
			end
		end
	end

	collector.done()
end

return M

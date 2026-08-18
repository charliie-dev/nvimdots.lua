return function()
	local resolver = require("core.global").is_mac and "grealpath" or "realpath"

	require("modules.utils").load_plugin("yazi", {
		integrations = {
			-- Upstream defaults to telescope, which this config no longer ships.
			grep_in_directory = "snacks.picker",
			grep_in_selected_files = "snacks.picker",
		},
		keymaps = vim.fn.executable(resolver) == 0 and {
			copy_relative_path_to_selected_files = false,
		} or nil,
	})
end

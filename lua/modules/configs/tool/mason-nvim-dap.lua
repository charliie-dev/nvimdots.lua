return function()
	-- Single setup() owner for mason-nvim-dap: reached by the spec's cmd trigger
	-- (:DapInstall/:DapUninstall) and by any require through lazy.nvim's module
	-- loader (the DAP resolver's factory branch and its mapping reads). setup()
	-- registers the :DapInstall/:DapUninstall user commands (api/command.lua has
	-- no other require site, and the plugin ships no plugin/ dir).
	require("modules.utils").load_plugin("mason-nvim-dap", {
		ensure_installed = {},
		automatic_installation = false,
	})
end

return function()
	-- Single setup() owner for mason-lspconfig: reached by the spec's cmd trigger
	-- (:LspInstall/:LspUninstall) and by any require through lazy.nvim's module
	-- loader (the LSP resolver's phase-2 mapping fetch). setup() registers the
	-- :LspInstall/:LspUninstall user commands (api/command.lua has no other
	-- require site, and the plugin ships no plugin/ dir) and kicks one async
	-- registry.refresh — a full registry update when the local cache is stale
	-- (>24h), not just alias registration — Mason-flavored paths only.
	require("modules.utils").load_plugin("mason-lspconfig", {
		ensure_installed = {},
		-- Skip auto enable because we are loading language servers lazily
		automatic_enable = false,
	})
end

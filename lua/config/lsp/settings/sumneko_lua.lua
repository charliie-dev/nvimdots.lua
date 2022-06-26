return {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" }, -- Add this for nvim "vim" intergration
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
			telemetry = {
				enable = false,
			},
		},
	},
}

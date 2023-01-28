-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/sumneko_lua.lua
-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

return {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
				path = runtime_path,
			},
			completion = {
				enable = true,
				callSnippet = "Both",
				keywordSnippet = "Both",
			},
			diagnostics = {
				enable = true,
				globals = { "vim" },
				-- neededFileStatus = { ["codestyle-check"] = "Any" },
			},
			workspace = {
				library = {
					vim.api.nvim_get_runtime_file("", true),
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
				},
				maxPreload = 2000,
				preloadFileSize = 1000,
			},
			telemetry = { enable = false },
			-- Do not override treesitter lua highlighting with sumneko lua highlighting
			semantic = { enable = false },
		},
	},
}

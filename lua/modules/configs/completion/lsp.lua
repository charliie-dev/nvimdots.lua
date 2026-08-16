return function()
	vim.diagnostic.config({
		signs = true,
		underline = true,
		virtual_text = false,
		update_in_insert = false,
	})

	local server = require("completion.lsp-server")
	local lsp_deps = require("core.settings").lsp_deps
	for _, entry in ipairs(lsp_deps) do
		server.register(entry)
	end

	pcall(require, "user.configs.lsp")
	require("completion.mason-registry").setup()

	for _, entry in ipairs(lsp_deps) do
		server.enable(entry)
	end
end

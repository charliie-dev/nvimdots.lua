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

	local user_config = "user.configs.lsp"
	local ok, err = pcall(require, user_config)
	if not ok and not tostring(err):find("module '" .. user_config .. "' not found:", 1, true) then
		error("Failed to load global LSP config: " .. tostring(err), 0)
	end
	for _, entry in ipairs(lsp_deps) do
		server.enable(entry)
	end
end

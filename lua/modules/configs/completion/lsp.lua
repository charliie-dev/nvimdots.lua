return function()
	require("completion.mason").setup()
	require("completion.mason-lspconfig").setup()

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local opts = {
		capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities({}, false)),
	}
	-- Configure LSPs that are not managed by Mason but are available in `nvim-lspconfig`.
	-- Servers are defined in `settings.external_lsp_deps` as { server_name = "executable" }.
	for lsp_name, exe in pairs(require("core.settings").external_lsp_deps) do
		if vim.fn.executable(exe) == 1 then
			local ok, _opts = pcall(require, "user.configs.lsp-servers." .. lsp_name)
			if not ok then
				local default_ok, default_opts = pcall(require, "completion.servers." .. lsp_name)
				if default_ok then
					_opts = default_opts
				end
			end
			if type(_opts) == "table" then
				local final_opts = vim.tbl_deep_extend("keep", _opts, opts)
				require("modules.utils").register_server(lsp_name, final_opts)
			else
				require("modules.utils").register_server(lsp_name, opts)
			end
		end
	end

	pcall(require, "user.configs.lsp")

	-- Start LSPs
	pcall(vim.cmd.LspStart)
end

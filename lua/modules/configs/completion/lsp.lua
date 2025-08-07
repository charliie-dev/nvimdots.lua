return function()
	require("completion.mason").setup()
	require("completion.mason-lspconfig").setup()

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local opts = {
		capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities({}, false)),
	}
	-- Configure LSPs that are not supported by `mason.nvim` but are available in `nvim-lspconfig`.
	-- First call |vim.lsp.config()|, then |vim.lsp.enable()| (or use `register_server`, see below)
	-- to ensure the language server is properly configured and starts automatically.
	if vim.fn.executable("dart") == 1 then
		local ok, _opts = pcall(require, "user.configs.lsp-servers.dartls")
		if not ok then
			_opts = require("completion.servers.dartls")
		end
		local final_opts = vim.tbl_deep_extend("keep", _opts, opts)
		require("modules.utils").register_server("dartls", final_opts)
	end

	pcall(require, "user.configs.lsp")

	-- Start LSPs
	pcall(vim.cmd.LspStart)
end

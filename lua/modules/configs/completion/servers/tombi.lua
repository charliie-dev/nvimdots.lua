-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/tombi.lua
-- mise config files go to `mise lsp` (servers/mise.lua), so the two servers do not report the same
-- keys twice. Every other TOML buffer keeps lspconfig's root markers.
local is_mise_config = require("modules.utils.mise").is_config

return {
	root_dir = function(bufnr, on_dir)
		if not is_mise_config(vim.api.nvim_buf_get_name(bufnr)) then
			on_dir(vim.fs.root(bufnr, { "tombi.toml", "pyproject.toml", ".git" }))
		end
	end,
	on_init = function(client, _)
		if client.server_capabilities then
			client.server_capabilities.semanticTokensProvider = nil
		end
	end,
}

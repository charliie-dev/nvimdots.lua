-- `mise lsp`: diagnostics, completion and hover for the config files mise loads, from the schema
-- of the installed mise. nvim-lspconfig has no definition for it. root_dir attaches it only to
-- mise config files, so other TOML buffers do not start a server that ignores them.
local is_mise_config = require("modules.utils.mise").is_config

return {
	cmd = { "mise", "lsp" },
	filetypes = { "toml" },
	root_dir = function(bufnr, on_dir)
		if is_mise_config(vim.api.nvim_buf_get_name(bufnr)) then
			on_dir(vim.fs.root(bufnr, { "mise.toml", ".mise.toml", "mise", ".mise", ".git" }))
		end
	end,
}

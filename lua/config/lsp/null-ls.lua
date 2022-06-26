local null_ls_status, null_ls = pcall(require, "null-ls")
if not null_ls_status then
	return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
	debug = false,
	sources = {
		formatting.prettier.with({
			extra_filetypes = { "toml" },
			extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
		}),
		formatting.black.with({ extra_args = { "--fast" } }),
		formatting.stylua,
		formatting.eslint,
		-- formatting.spll,
		formatting.reorder_python_imports,
		diagnostics.flake8,
		diagnostics.pylint,
	},
})

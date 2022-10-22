local null_ls = require("null-ls")

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
	debug = false,
	sources = {
		formatting.prettierd.with({
			extra_filetypes = { "toml" },
			extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
		}),
		formatting.black.with({ extra_args = { "--fast" } }),
		formatting.stylua,
		formatting.shfmt,
		formatting.isort,
		formatting.markdownlint,
		formatting.cbfmt,
		diagnostics.eslint_d,
		diagnostics.flake8,
		diagnostics.shellcheck,
		diagnostics.markdownlint.with({
			extra_args = { "--disable MD033" },
		}),
		-- null_ls.builtins.code_actions.gitsigns, -- retrieve code actions from lewis6991/gitsigns.nvim, comment out to avoid code_actions lightball
	},
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format()
					vim.notify("Formatted by null-ls!", vim.log.levels.INFO, { title = "LspFormat" })
				end,
			})
		end
	end,
})

-- NOTE: if you want to use local executables.
-- local sources = {
--     null_ls.builtins.formatting.prettier.with({
--         command = "/path/to/prettier",
--     }),
-- }

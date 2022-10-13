local null_ls = require("null-ls")

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

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
		formatting.eslint_d,
		formatting.isort,
		formatting.codespell,
		formatting.markdownlint,
		formatting.cbfmt,
		diagnostics.flake8,
		diagnostics.pylint,
		diagnostics.shellcheck,
		-- null_ls.builtins.code_actions.gitsigns, -- retrieve code actions from lewis6991/gitsigns.nvim, comment out to avoid code_actions lightball
	},
})

-- local unwrap = {
--   method = null_ls.methods.DIAGNOSTICS,
--   filetypes = { "rust" },
--   generator = {
--     fn = function(params)
--       local diagnostics = {}
--       -- sources have access to a params object
--       -- containing info about the current file and editor state
--       for i, line in ipairs(params.content) do
--         local col, end_col = line:find "unwrap()"
--         if col and end_col then
--           -- null-ls fills in undefined positions
--           -- and converts source diagnostics into the required format
--           table.insert(diagnostics, {
--             row = i,
--             col = col,
--             end_col = end_col,
--             source = "unwrap",
--             message = "hey " .. os.getenv("USER") .. ", don't forget to handle this" ,
--             severity = 2,
--           })
--         end
--       end
--       return diagnostics
--     end,
--   },
-- }

-- null_ls.register(unwrap)

-- NOTE: if you want to use local executables.
-- local sources = {
--     null_ls.builtins.formatting.prettier.with({
--         command = "/path/to/prettier",
--     }),
-- }

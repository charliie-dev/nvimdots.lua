return function()
	-- Server resolution (Mason-installed / on $PATH / installable / missing) is handled
	-- discovery-first in `mason-lspconfig.setup`, driven by `settings.lsp_deps`.
	require("completion.mason-lspconfig").setup()

	-- Run `user.configs.lsp` with its vim.lsp.config registrations recorded: a
	-- mid-session install registers after this point, and the replay keeps the
	-- user's overrides on top regardless of timing.
	-- `user.configs.lsp-servers.<name>` remains the richer per-server hook.
	require("completion.mason-lspconfig").run_user_lsp_overrides()

	-- Start LSPs
	pcall(vim.cmd.LspStart)
end

return function()
	-- Handler/probe machinery first (no discovery yet): sets up the read
	-- trigger the override pass below relies on.
	require("completion.mason-lspconfig").setup()

	-- Run `user.configs.lsp` with its vim.lsp.config registrations recorded: a
	-- mid-session install registers after this point, and the replay keeps the
	-- user's overrides on top regardless of timing.
	-- `user.configs.lsp-servers.<name>` remains the richer per-server hook.
	require("completion.mason-lspconfig").run_user_lsp_overrides()

	-- Discovery LAST (Mason-installed / on $PATH / installable / missing,
	-- driven by `settings.lsp_deps`): user runtime registrations above must be
	-- visible to the unknown/binary classification.
	require("completion.mason-lspconfig").resolve_deps()

	-- Start LSPs
	pcall(vim.cmd.LspStart)
end

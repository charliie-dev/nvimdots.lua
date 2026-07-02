return function()
	-- Server resolution (Mason-installed / on $PATH / installable / missing) is
	-- handled centrally and discovery-first in `mason-lspconfig.setup`, driven by
	-- the single `settings.lsp_deps` list.
	require("completion.mason-lspconfig").setup()

	pcall(require, "user.configs.lsp")

	-- Start LSPs
	pcall(vim.cmd.LspStart)
end

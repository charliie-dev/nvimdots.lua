return function()
	local settings = require("core.settings")

	require("muster").setup({
		lsp = vim.deepcopy(settings.lsp_deps),
		conform = vim.deepcopy(settings.formatter_deps),
		nvim_lint = vim.deepcopy(settings.linter_deps),
		dap = vim.deepcopy(settings.dap_deps),
		mason_install_fallback = false,
		notify_on_startup = true,
	})
end

require("project_nvim").setup({
	manual_mode = true, -- use `:ProjectRoot` to switch to project root
	detection_methods = { "lsp", "pattern" },
	patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
	ignore_lsp = { "null-ls", "copilot" },
	exclude_dirs = {},
	show_hidden = false,
	silent_chdir = true,
	scope_chdir = "global",
	datapath = vim.fn.stdpath("data"),
})

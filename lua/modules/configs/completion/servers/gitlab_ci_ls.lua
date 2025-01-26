-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/gitlab_ci_ls.lua
local util = require("lspconfig.util")
local cache_dir = vim.loop.os_homedir() .. "/.cache/gitlab-ci-ls/"
return {
	cmd = { "gitlab-ci-ls" },
	filetypes = { "yaml.gitlab" },
	root_dir = util.root_pattern(".gitlab*", ".git"),
	init_options = {
		cache_path = cache_dir,
		log_path = cache_dir .. "/log/gitlab-ci-ls.log",
	},
}

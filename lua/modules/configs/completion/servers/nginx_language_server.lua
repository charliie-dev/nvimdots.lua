-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/nginx_language_server.lua
local util = require("lspconfig.util")
return {
	cmd = { "nginx-language-server" },
	filetypes = { "nginx" },
	root_dir = function(fname)
		return util.root_pattern("nginx.conf", ".git")(fname)
			or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
	end,
	single_file_support = true,
}

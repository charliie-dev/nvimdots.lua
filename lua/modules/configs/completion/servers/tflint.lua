-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/tflint.lua
-- `tflint --langserver` loads its config once at startup from the process cwd (falling back to
-- ~/.tflint.hcl), then chdirs into each opened file's directory. Neovim spawns servers from its
-- own cwd, so a repo-root .tflint.hcl was ignored when nvim started elsewhere. Spawn from root_dir
-- instead, and prefer the nearest .tflint.hcl as the root so that config is the one loaded.
return {
	cmd = function(dispatchers, config)
		return vim.lsp.rpc.start({ "tflint", "--langserver" }, dispatchers, { cwd = config.root_dir })
	end,
	root_markers = { ".tflint.hcl", ".terraform", ".git" },
}

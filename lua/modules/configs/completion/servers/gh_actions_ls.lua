-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/gh_actions_ls.lua
return {
	cmd = { "gh-actions-language-server", "--stdio" },
	filetypes = { "yaml" },

	-- `root_dir` ensures that the LSP does not attach to all yaml files
	root_dir = function(bufnr, on_dir)
		local parent = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
		if
			vim.endswith(parent, "/.github/workflows")
			or vim.endswith(parent, "/.forgejo/workflows")
			or vim.endswith(parent, "/.gitea/workflows")
		then
			on_dir(parent)
		end
	end,

	capabilities = {
		workspace = {
			didChangeWorkspaceFolders = {
				dynamicRegistration = true,
			},
		},
	},
}

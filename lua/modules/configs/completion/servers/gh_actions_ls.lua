-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/gh_actions_ls.lua
return {
	cmd = { "gh-actions-language-server", "--stdio" },
	filetypes = { "yaml.github" },

	-- Only attach to yaml files that are GitHub workflows instead of all yaml
	-- files. (A nil root_dir and no single_file_support results in the LSP not
	-- attaching.) For details, see #3558
	root_dir = function(filename)
		local dirs_to_check = {
			".github/workflows",
			".forgejo/workflows",
			".gitea/workflows",
		}

		local dir = vim.fs.dirname(filename)
		for _, subdir in ipairs(dirs_to_check) do
			local match = vim.fs.find(subdir, { path = dir, upward = true })[1]
			if match and vim.fn.isdirectory(match) == 1 and vim.fs.dirname(filename) == match then
				return match
			end
		end

		return nil
	end,

	-- Disabling "single file support" is a hack to avoid enabling this LS for
	-- every random yaml file, so `root_dir()` can control the enablement.
	single_file_support = false,

	capabilities = {
		workspace = {
			didChangeWorkspaceFolders = {
				dynamicRegistration = true,
			},
		},
	},
}

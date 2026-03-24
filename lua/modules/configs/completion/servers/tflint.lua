-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/tflint.lua
return {
	cmd = { "tflint", "--langserver" },
	filetypes = { "terraform" },
	root_markers = { ".terraform", ".tflint.hcl", ".git" },
}

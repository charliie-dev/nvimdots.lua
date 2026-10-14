-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/terraformls.lua
-- terraform-ls has no log level: it logs every LSP request and response to stderr, which Neovim
-- records at ERROR level, so it filled most of lsp.log. Discard those logs instead; to debug the
-- server, point `-log-file` at an absolute path.
return {
	cmd = { "terraform-ls", "serve", "-log-file=/dev/null" },
}

local status, _ = pcall(require, "lspconfig")
if not status then
	return
end

require("config.lsp.handlers").setup()
require("config.lsp.fidget")
require("config.lsp.hlargs")
require("config.lsp.lsp-colors")
require("config.lsp.lsp-installer")
require("config.lsp.lsp-signature")
require("config.lsp.null-ls")
require("config.lsp.ts-context")


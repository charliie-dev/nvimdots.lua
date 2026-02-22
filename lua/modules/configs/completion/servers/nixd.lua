-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/nixd.lua
return {
	cmd = {
		"nixd",
		"--inlay-hints=false",
		"--semantic-tokens=false",
	},
	single_file_support = true,
	on_init = function(client, _)
		if client.server_capabilities then
			-- Disable everything except completionProvider
			client.server_capabilities.hoverProvider = nil
			client.server_capabilities.definitionProvider = nil
			client.server_capabilities.referencesProvider = nil
			client.server_capabilities.declarationProvider = nil
			client.server_capabilities.typeDefinitionProvider = nil
			client.server_capabilities.implementationProvider = nil
			client.server_capabilities.documentFormattingProvider = nil
			client.server_capabilities.documentRangeFormattingProvider = nil
			client.server_capabilities.documentHighlightProvider = nil
			client.server_capabilities.documentSymbolProvider = nil
			client.server_capabilities.workspaceSymbolProvider = nil
			client.server_capabilities.codeActionProvider = nil
			client.server_capabilities.codeLensProvider = nil
			client.server_capabilities.renameProvider = nil
			client.server_capabilities.signatureHelpProvider = nil
			client.server_capabilities.semanticTokensProvider = nil
			client.server_capabilities.inlayHintProvider = nil
			client.server_capabilities.diagnosticProvider = nil
			client.server_capabilities.documentLinkProvider = nil
			client.server_capabilities.foldingRangeProvider = nil
			client.server_capabilities.selectionRangeProvider = nil
			client.server_capabilities.callHierarchyProvider = nil
			client.server_capabilities.typeHierarchyProvider = nil
		end
	end,
	handlers = {
		-- Suppress all diagnostics from nixd
		["textDocument/publishDiagnostics"] = function() end,
	},
}

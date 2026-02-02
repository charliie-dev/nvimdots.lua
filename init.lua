if not vim.g.vscode then
	-- only needed when managing nvim dependencies from home-manager, otherwise comment this line
	_, _ = pcall(require, "hm-generated")
	require("core")
end

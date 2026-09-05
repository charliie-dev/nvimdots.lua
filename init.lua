if not vim.g.vscode then
	-- only needed when managing nvim dependencies from home-manager, otherwise comment this line
	pcall(require, "hm-generated")
	-- Cache core modules and plugin configs before lazy.nvim enables the same loader.
	vim.loader.enable()
	require("core")
end

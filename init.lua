if not vim.g.vscode then
	-- only needed when managing nvim dependencies from home-manager, otherwise comment this line
	local has_generated, _ = pcall(require, "nix-generated")
	if has_generated then
		require("nix-generated")
	end
	require("core")
end

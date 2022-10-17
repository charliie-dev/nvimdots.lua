-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/ltex.lua
-- https://gist.github.com/lbiaggi/a3eb761ac2fdbff774b29c88844355b8

local Dictionary_file = {
	["en-US"] = { os.getenv("HOME") .. "/.config/nvim/spell/dictionary.txt" }, -- there is another way to find ~/.config/nvim ?
}

local function readFiles(files)
	local dict = {}
	for _, file in ipairs(files) do
		if not file then
			return nil
		end

		for line in io.lines(file) do
			table.insert(dict, line)
		end
	end
	return dict
end

return {
	settings = {
		ltex = {
			language = "en-US",
			dictionary = {
				["en-US"] = readFiles(Dictionary_file["en-US"] or {}),
			},
		},
	},
}

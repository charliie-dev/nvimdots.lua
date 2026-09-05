local M = {}

local saved = {}
local evaluate

local function global_map(mode)
	for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
		if map.lhs == "K" then
			return map
		end
	end
end

function M.load_extras()
	if evaluate then
		return
	end
	evaluate = function()
		require("dapui").eval()
	end
	-- LSP buffers dispatch locally; never capture a buffer's fallback as a global mapping.
	for _, mode in ipairs({ "n", "x", "s" }) do
		saved[mode] = global_map(mode) or false
		vim.keymap.set(mode, "K", evaluate, { nowait = true, desc = "Debugging: Evaluate expression under cursor" })
	end
end

function M.unload_extras()
	for mode, map in pairs(saved) do
		local current = global_map(mode)
		-- A user mapping installed during the session takes precedence over restoration.
		if current and current.callback == evaluate then
			vim.keymap.del(mode, "K")
			if map then
				vim.fn.mapset(mode, false, map)
			end
		end
	end
	saved = {}
	evaluate = nil
end

return M

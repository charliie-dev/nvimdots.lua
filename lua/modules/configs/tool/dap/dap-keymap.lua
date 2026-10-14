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

-- dapui only reads charwise Visual selections; Visual line/block and Select mode fall back to
-- <cexpr>. Read every Visual and Select variant here and pass the text explicitly.
local region_types = { v = "v", V = "V", ["\22"] = "\22", s = "v", S = "V", ["\19"] = "\22" }

local function selected_expression()
	local region_type = region_types[vim.fn.mode()]
	if not region_type then
		return nil
	end
	return table.concat(vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = region_type }), "\n")
end

function M.load_extras()
	if evaluate then
		return
	end
	evaluate = function()
		require("dapui").eval(selected_expression())
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

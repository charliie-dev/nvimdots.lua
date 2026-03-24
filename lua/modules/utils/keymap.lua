local M = {}

---Shortcut for `nvim_replace_termcodes`.
---@param keys string
---@return string
local function termcodes(keys)
	return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

---Returns if two key sequence are equal or not.
---@param a string
---@param b string
---@return boolean
local function keymap_equals(a, b)
	return termcodes(a) == termcodes(b)
end

---Get and remove an existing mapping, returning its properties.
---@param mode string
---@param lhs string
---@return table
local function get_map(mode, lhs)
	for _, map in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
		if keymap_equals(map.lhs, lhs) then
			vim.api.nvim_buf_del_keymap(0, mode, lhs)
			return {
				lhs = map.lhs,
				rhs = map.rhs or "",
				expr = map.expr == 1,
				callback = map.callback,
				noremap = map.noremap == 1,
				script = map.script == 1,
				silent = map.silent == 1,
				nowait = map.nowait == 1,
				buffer = true,
			}
		end
	end

	for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
		if keymap_equals(map.lhs, lhs) then
			vim.api.nvim_del_keymap(mode, lhs)
			return {
				lhs = map.lhs,
				rhs = map.rhs or "",
				expr = map.expr == 1,
				callback = map.callback,
				noremap = map.noremap == 1,
				script = map.script == 1,
				silent = map.silent == 1,
				nowait = map.nowait == 1,
				buffer = false,
			}
		end
	end

	return {
		lhs = lhs,
		rhs = lhs,
		expr = false,
		callback = nil,
		noremap = true,
		script = false,
		silent = true,
		nowait = false,
		buffer = false,
	}
end

---Returns a function that executes the original keymapping as a fallback.
---@param map table keymap object
---@return function
local function get_fallback(map)
	return function()
		local keys, fmode
		if map.expr then
			if map.callback then
				keys = map.callback()
			else
				keys = vim.api.nvim_eval(map.rhs)
			end
		elseif map.callback then
			map.callback()
			return
		else
			keys = map.rhs
		end
		keys = termcodes(keys)
		fmode = map.noremap and "in" or "im"
		vim.api.nvim_feedkeys(keys, fmode, false)
	end
end

---Amend an existing keymap with conditional behavior.
---When `_G[global_flag]` is true, execute `rhs`; otherwise fall back to the original mapping.
---@param cond string @Condition label for the description
---@param global_flag string @Global variable name to check
---@param mode string|string[] @Mode(s) for the keymap
---@param lhs string @Left-hand side key sequence
---@param rhs string|function @Right-hand side to execute when condition is met
---@param opts? table @Additional keymap options
function M.amend(cond, global_flag, mode, lhs, rhs, opts)
	local modes = type(mode) == "table" and mode or { mode }
	for _, m in ipairs(modes) do
		local map = get_map(m, lhs)
		local fallback = get_fallback(map)
		local options = vim.deepcopy(opts) or {}
		options.desc = table.concat({
			"[" .. cond,
			(options.desc and ": " .. options.desc or ""),
			"]",
			(map.desc and " / " .. map.desc or ""),
		})
		vim.keymap.set(m, lhs, function()
			if _G[global_flag] then
				if type(rhs) == "function" then
					rhs()
				else
					-- NOTE: "in" = noremap insert mode; assumes all amended rhs should be noremap
					vim.api.nvim_feedkeys(termcodes(rhs), "in", false)
				end
			else
				fallback()
			end
		end, options)
	end
end

---Replace existing keymaps.
---Each entry is a tuple: { mode, lhs, rhs, opts? }
---Pass `false` as an entry to delete a mapping.
---@param mappings table[] @List of { mode, lhs, rhs, opts? } tuples
function M.replace(mappings)
	for _, entry in ipairs(mappings) do
		if type(entry) == "table" then
			local mode, lhs, rhs, opts = entry[1], entry[2], entry[3], entry[4]
			local modes = type(mode) == "table" and mode or { mode }
			for _, m in ipairs(modes) do
				get_map(m, lhs) -- remove existing mapping first
			end
			if rhs then
				vim.keymap.set(mode, lhs, rhs, opts or {})
			end
		end
	end
end

return M

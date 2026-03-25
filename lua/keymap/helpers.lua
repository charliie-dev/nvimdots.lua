local M = {}

M.command_panel = function()
	require("snacks").picker.keymaps()
end

M.flash_esc_or_noh = function()
	local flash_active, state = pcall(function()
		return require("flash.plugins.char").state
	end)
	if flash_active and state then
		state:hide()
	else
		pcall(vim.cmd.noh)
	end
end

M.persisted_sessions = function()
	local config = require("persisted.config")
	local sessions = require("persisted").list()
	local items = {}
	for _, session in ipairs(sessions) do
		local file = session:sub(#config.save_dir + 1, -5)
		local dir, branch = unpack(vim.split(file, "@@", { plain = true }))
		dir = dir:gsub("%%", "/")
		local name = vim.fn.fnamemodify(dir, ":p:~")
		if branch then
			name = name .. " (" .. branch .. ")"
		end
		items[#items + 1] = { text = name, file = session }
	end
	require("snacks").picker.pick({
		title = "Sessions",
		items = items,
		format = function(item)
			return { { item.text } }
		end,
		confirm = function(picker, item)
			picker:close()
			if item then
				require("persisted").load({ session = item.file })
			end
		end,
	})
end

M.toggle_inlayhint = function()
	local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })

	vim.lsp.inlay_hint.enable(not is_enabled)
	vim.notify(
		(is_enabled and "Inlay hint disabled successfully" or "Inlay hint enabled successfully"),
		vim.log.levels.INFO,
		{ title = "LSP Inlay Hint" }
	)
end

M.toggle_virtuallines = function()
	require("tiny-inline-diagnostic").toggle()
	vim.notify(
		"Virtual lines are now "
			.. (require("tiny-inline-diagnostic.diagnostic").user_toggle_state and "displayed" or "hidden"),
		vim.log.levels.INFO,
		{ title = "LSP Diagnostic" }
	)
end

---@param program string
local function not_found_notify(program)
	vim.notify(string.format("[%s] not found!", program), vim.log.levels.ERROR, { title = "Terminal" })
end

---Toggle a floating terminal running `cmd`.
---@param cmd string
---@param program string
M.toggle_float_term = function(cmd, program)
	if vim.fn.executable(program) == 1 then
		require("snacks").terminal.toggle(cmd, { win = { style = "float" } })
	else
		not_found_notify(program)
	end
end

return M

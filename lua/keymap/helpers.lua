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

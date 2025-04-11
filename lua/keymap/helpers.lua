_G._command_panel = function()
	require("telescope.builtin").keymaps({
		lhs_filter = function(lhs)
			return not string.find(lhs, "Þ")
		end,
	})
end

_G._flash_esc_or_noh = function()
	local flash_active, state = pcall(function()
		return require("flash.plugins.char").state
	end)
	if flash_active and state then
		state:hide()
	else
		pcall(vim.cmd.noh)
	end
end

_G._telescope_collections = function(picker_type)
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local pickers = require("telescope.pickers")
	local finder = require("telescope.finders")
	local conf = require("telescope.config").values
	picker_type = picker_type or {}

	local collections = vim.tbl_keys(require("search.tabs").collections)
	pickers
		.new(picker_type, {
			prompt_title = "Telescope Collections",
			finder = finder.new_table({ results = collections }),
			sorter = conf.generic_sorter(picker_type),
			attach_mappings = function(bufnr)
				actions.select_default:replace(function()
					actions.close(bufnr)
					local selection = action_state.get_selected_entry()
					require("search").open({ collection = selection[1] })
				end)

				return true
			end,
		})
		:find()
end

_G._toggle_inlayhint = function()
	local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })

	vim.lsp.inlay_hint.enable(not is_enabled)
	vim.notify(
		(is_enabled and "Inlay hint disabled successfully" or "Inlay hint enabled successfully"),
		vim.log.levels.INFO,
		{ title = "LSP Inlay Hint" }
	)
end

_G._toggle_virtualtext = function()
	local _vt_enabled = require("core.settings").diagnostics_virtual_text
	if _vt_enabled then
		local vt_config = not vim.diagnostic.config().virtual_text
		vim.diagnostic.config({ virtual_text = vt_config })
		vim.notify(
			(vt_config and "Virtual text is now displayed" or "Virtual text is now hidden"),
			vim.log.levels.INFO,
			{ title = "LSP Diagnostic" }
		)
	end

	local _vl_enabled = require("core.settings").diagnostics_virtual_lines
	if _vl_enabled then
		local vl_config = not vim.diagnostic.config().virtual_lines
		vim.diagnostic.config({ virtual_lines = vl_config })
		vim.notify(
			(vl_config and "Virtual lines is now displayed" or "Virtual lines is now hidden"),
			vim.log.levels.INFO,
			{ title = "LSP Diagnostic" }
		)
	end
end

---@param program string
local function not_found_notify(program)
	vim.notify(string.format("[%s] not found!", program), vim.log.levels.ERROR, { title = "toggleterm.nvim" })
end

local toggleterm_cache = {
	lazygit = nil,
	yazi = nil,
	btop = nil,
	python = nil,
	nvsmi = nil,
}

_G._toggle_lazygit = function()
	if vim.fn.executable("lazygit") == 1 then
		if not toggleterm_cache.lazygit then
			toggleterm_cache.lazygit = require("toggleterm.terminal").Terminal:new({
				cmd = "lazygit",
				direction = "float",
				close_on_exit = true,
				hidden = true,
			})
		end
		toggleterm_cache.lazygit:toggle()
	else
		not_found_notify("lazygit")
	end
end

_G._toggle_yazi = function()
	if vim.fn.executable("yazi") == 1 then
		if not toggleterm_cache.yazi then
			toggleterm_cache.yazi = require("toggleterm.terminal").Terminal:new({
				cmd = "yazi",
				direction = "float",
				close_on_exit = true,
				hidden = true,
			})
		end
		toggleterm_cache.yazi:toggle()
	else
		not_found_notify("yazi")
	end
end

_G._toggle_btop = function()
	if vim.fn.executable("btop") == 1 then
		if not toggleterm_cache.btop then
			toggleterm_cache.btop = require("toggleterm.terminal").Terminal:new({
				cmd = "btop",
				direction = "float",
				close_on_exit = true,
				hidden = true,
			})
		end
		toggleterm_cache.btop:toggle()
	else
		not_found_notify("btop")
	end
end

_G._toggle_python = function()
	if vim.fn.executable("python3") == 1 then
		if not toggleterm_cache.python then
			toggleterm_cache.python = require("toggleterm.terminal").Terminal:new({
				cmd = "python3",
				direction = "float",
				close_on_exit = true,
				hidden = true,
			})
		elseif vim.fn.executable("python") == 1 then
			toggleterm_cache.python = require("toggleterm.terminal").Terminal:new({
				cmd = "python",
				direction = "float",
				close_on_exit = true,
				hidden = true,
			})
		end
		toggleterm_cache:python()
	else
		not_found_notify("python3 or python")
	end
end

_G._toggle_nvsmi = function()
	if vim.fn.executable("nvidia-smi") == 1 then
		if not toggleterm_cache.nvsmi then
			toggleterm_cache.nvsmi = require("toggleterm.terminal").Terminal:new({
				cmd = "watch -n 1 nvidia-smi",
				direction = "float",
				close_on_exit = true,
				hidden = true,
			})
		end
		toggleterm_cache.nvsmi()
	else
		not_found_notify("nvidia-smi")
	end
end

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
	local is_enabled = vim.lsp.inlay_hint.is_enabled()

	vim.lsp.inlay_hint.enable(not is_enabled)
	vim.notify(
		(is_enabled and "Inlay hint disabled successfully" or "Inlay hint enabled successfully"),
		vim.log.levels.INFO,
		{ title = "LSP Inlay Hint" }
	)
end

local _vt_enabled = require("core.settings").diagnostics_virtual_text
_G._toggle_virtualtext = function()
	if vim.diagnostic.is_enabled() then
		_vt_enabled = not _vt_enabled
		vim.diagnostic[_vt_enabled and "show" or "hide"]()
		vim.notify(
			(_vt_enabled and "Virtual text is now displayed" or "Virtual text is now hidden"),
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

function _G._toggle_yazi()
	if toggleterm_cache.yazi then
		toggleterm_cache.lf:toggle()
	else
		if vim.fn.executable("yazi") then
			toggleterm_cache.yazi =
				require("toggleterm.terminal").Terminal:new({ cmd = "yazi", hidden = true, direction = "float" })
			toggleterm_cache.yazi:toggle()
		else
			not_found_notify("yazi")
		end
	end
end

function _G._toggle_btop()
	if toggleterm_cache.btop then
		toggleterm_cache.btop:toggle()
	else
		if vim.fn.executable("btop") then
			toggleterm_cache.btop =
				require("toggleterm.terminal").Terminal:new({ cmd = "btop", hidden = true, direction = "float" })
			toggleterm_cache.btop:toggle()
		else
			not_found_notify("btop")
		end
	end
end

function _G._toggle_py()
	if toggleterm_cache.python then
		toggleterm_cache.python:toggle()
	else
		if vim.fn.executable("python3") then
			toggleterm_cache.python =
				require("toggleterm.terminal").Terminal:new({ cmd = "python3", hidden = true, direction = "float" })
			toggleterm_cache.python:toggle()
		elseif vim.fn.executable("python") then
			toggleterm_cache.python =
				require("toggleterm.terminal").Terminal:new({ cmd = "python", hidden = true, direction = "float" })
			toggleterm_cache.python:toggle()
		else
			not_found_notify("python")
		end
	end
end

function _G._toggle_nvsmi()
	if toggleterm_cache.nvsmi then
		toggleterm_cache.nvsmi:toggle()
	else
		if vim.fn.executable("nvidia-smi") then
			toggleterm_cache.nvsmi = require("toggleterm.terminal").Terminal:new({
				cmd = "watch -n 1 nvidia-smi",
				hidden = true,
				direction = "float",
			})
			toggleterm_cache.nvsmi:toggle()
		else
			not_found_notify("nvidia-smi")
		end
	end
end

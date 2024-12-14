_G._command_panel = function()
	require("telescope.builtin").keymaps({
		lhs_filter = function(lhs)
			return not string.find(lhs, "Þ")
		end,
		layout_config = {
			width = 0.6,
			height = 0.6,
			prompt_position = "top",
		},
	})
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

_G._toggle_inlayhint = function()
	if vim.lsp.inlay_hint.is_enabled() then
		vim.lsp.inlay_hint.enable(false)
		vim.notify("Disable inlay hint successfully!", vim.log.levels.INFO, { title = "LSP Inlay Hint" })
	else
		vim.lsp.inlay_hint.enable(true)
		vim.notify("Enable inlay hint successfully!", vim.log.levels.INFO, { title = "LSP Inlay Hint" })
	end
end

local _diagnostic = 1
_G._toggle_diagnostic = function()
	if vim.diagnostic.is_enabled() then
		if _diagnostic == 1 then
			_diagnostic = 0
			vim.diagnostic.hide()
			vim.notify("Hide virtual text successfully!", vim.log.levels.INFO, { title = "LSP Diagnostic" })
		else
			_diagnostic = 1
			vim.diagnostic.show()
			vim.notify("Show virtual text successfully!", vim.log.levels.INFO, { title = "LSP Diagnostic" })
		end
	end
end

---@param program string
local function not_found_notify(program)
	vim.notify(string.format("[%s] not found!", program), vim.log.levels.ERROR, { title = "toggleterm.nvim" })
end

local toggleterm_cache = {
	lazygit = nil,
	lf = nil,
	htop = nil,
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

function _G.toggle_lf()
	if toggleterm_cache.lf then
		toggleterm_cache.lf:toggle()
	else
		if vim.fn.executable("lf") then
			toggleterm_cache.lf =
				require("toggleterm.terminal").Terminal:new({ cmd = "lf", hidden = true, direction = "float" })
			toggleterm_cache.lf:toggle()
		else
			not_found_notify("Lf")
		end
	end
end

function _G.toggle_htop()
	if toggleterm_cache.htop then
		toggleterm_cache.htop:toggle()
	else
		if vim.fn.executable("htop") then
			toggleterm_cache.htop =
				require("toggleterm.terminal").Terminal:new({ cmd = "htop", hidden = true, direction = "float" })
			toggleterm_cache.htop:toggle()
		else
			not_found_notify("Htop")
		end
	end
end

function _G.toggle_py()
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
			not_found_notify("Python")
		end
	end
end

function _G.toggle_nvsmi()
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

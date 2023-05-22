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

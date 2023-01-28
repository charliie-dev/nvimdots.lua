require("toggleterm").setup({
	-- size can be a number or function which is passed the current terminal
	size = function(term)
		if term.direction == "horizontal" then
			return 20
		elseif term.direction == "vertical" then
			return vim.o.columns * 0.40
		end
	end,
	on_open = function()
		-- Prevent infinite calls from freezing neovim.
		-- Only set these options specific to this terminal buffer.
		vim.api.nvim_set_option_value("foldmethod", "manual", { scope = "local" })
		vim.api.nvim_set_option_value("foldexpr", "0", { scope = "local" })
	end,
	open_mapping = [[<c-\>]],
	hide_numbers = true, -- hide the number column in toggleterm buffers
	shade_filetypes = {},
	shade_terminals = false,
	shading_factor = "1", -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
	start_in_insert = true,
	insert_mappings = true, -- whether or not the open mapping applies in insert mode
	persist_size = true,
	direction = "horizontal",
	close_on_exit = true, -- close the terminal window when the process exits
	shell = vim.o.shell, -- change the default shell
})

function _G.set_terminal_keymaps()
	local opts = { noremap = true }
	vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
end

vim.api.nvim_command("autocmd! TermOpen term://* lua set_terminal_keymaps()")

local Terminal = require("toggleterm.terminal").Terminal

local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float" })

function _LAZYGIT_TOGGLE()
	lazygit:toggle()
end

local lf = Terminal:new({ cmd = "lf", hidden = true, direction = "float" })

function _LF_TOGGLE()
	lf:toggle()
end

local htop = Terminal:new({ cmd = "htop", hidden = true, direction = "float" })

function _HTOP_TOGGLE()
	htop:toggle()
end

local python = Terminal:new({ cmd = "python", hidden = true, direction = "float" })

function _PYTHON_TOGGLE()
	python:toggle()
end

local nvsmi = Terminal:new({ cmd = "watch -n 1 nvidia-smi", hidden = true, direction = "float" })

function _NVSMI_TOGGLE()
	nvsmi:toggle()
end

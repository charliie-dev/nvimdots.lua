local icon = require("modules.ui.icons")

local function set_sidebar_icons()
	-- Set icons for sidebar.
	local diagnostic_icons = {
		Error = icon.diagnostics.Error_alt,
		Warn = icon.diagnostics.Warning_alt,
		Info = icon.diagnostics.Information_alt,
		Hint = icon.diagnostics.Hint_alt,
	}
	for type, diag_icon in pairs(diagnostic_icons) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = diag_icon, texthl = hl })
	end
end

local function get_palette()
	-- Default behavior: return lspsaga's default palette.
	local palette = require("lspsaga.lspkind").colors
	palette.peach = palette.orange
	palette.flamingo = palette.orange
	palette.rosewater = palette.yellow
	palette.mauve = palette.violet
	palette.sapphire = palette.blue
	palette.maroon = palette.orange

	return palette
end

set_sidebar_icons()

local colors = get_palette()

require("lspsaga").init_lsp_saga({
	border_style = "plus",
	code_action_icon = "💡",
	diagnostic_header = {
		icon.diagnostics.Error_alt .. " ",
		icon.diagnostics.Warning_alt .. " ",
		icon.diagnostics.Information_alt .. " ",
		icon.diagnostics.Hint_alt .. " ",
	},
	custom_kind = {
		Class = { icon.kind.Class .. " ", colors.yellow },
		Constant = { icon.kind.Constant .. " ", colors.peach },
		Constructor = { icon.kind.Constructor .. " ", colors.sapphire },
		Enum = { icon.kind.Enum .. " ", colors.yellow },
		EnumMember = { icon.kind.EnumMember .. " ", colors.teal },
		Event = { icon.kind.Event .. " ", colors.yellow },
		Field = { icon.kind.Field .. " ", colors.teal },
		File = { icon.kind.File .. " ", colors.rosewater },
		Function = { icon.kind.Function .. " ", colors.blue },
		Interface = { icon.kind.Interface .. " ", colors.yellow },
		Key = { icon.kind.Keyword .. " ", colors.red },
		Method = { icon.kind.Method .. " ", colors.blue },
		Module = { icon.kind.Module .. " ", colors.blue },
		Namespace = { icon.kind.Namespace .. " ", colors.blue },
		Number = { icon.kind.Number .. " ", colors.peach },
		Operator = { icon.kind.Operator .. " ", colors.sky },
		Package = { icon.kind.Package .. " ", colors.blue },
		Property = { icon.kind.Property .. " ", colors.teal },
		Struct = { icon.kind.Struct .. " ", colors.yellow },
		TypeParameter = { icon.kind.TypeParameter .. " ", colors.maroon },
		Variable = { icon.kind.Variable .. " ", colors.peach },
		-- Type
		Array = { icon.type.Array .. " ", colors.peach },
		Boolean = { icon.type.Boolean .. " ", colors.peach },
		Null = { icon.type.Null .. " ", colors.yellow },
		Object = { icon.type.Object .. " ", colors.yellow },
		String = { icon.type.String .. " ", colors.green },
		-- ccls-specific icons.
		TypeAlias = { icon.kind.TypeAlias .. " ", colors.green },
		Parameter = { icon.kind.Parameter .. " ", colors.blue },
		StaticMethod = { icon.kind.StaticMethod .. " ", colors.peach },
		Macro = { icon.kind.Macro .. " ", colors.red },
	},
	symbol_in_winbar = {
		in_custom = true,
		enable = true,
		separator = " " .. icon.ui.Separator .. " ",
		show_file = true,
		click_support = function(node, clicks, button, modifiers)
			-- To see all avaiable details: vim.pretty_print(node)
			local st = node.range.start
			local en = node.range["end"]
			if button == "l" then
				if clicks == 2 then
				-- double left click to do nothing
				else -- jump to node's starting line+char
					vim.fn.cursor(st.line + 1, st.character + 1)
				end
			elseif button == "r" then
				if modifiers == "s" then
					print("lspsaga") -- shift right click to print "lspsaga"
				end -- jump to node's ending line+char
				vim.fn.cursor(en.line + 1, en.character + 1)
			elseif button == "m" then
				-- middle click to visual select node
				vim.fn.cursor(st.line + 1, st.character + 1)
				vim.api.nvim_command("normal v")
				vim.fn.cursor(en.line + 1, en.character + 1)
			end
		end,
	},
})

-- Example:
local function get_file_name(include_path)
	local file_name = require("lspsaga.symbolwinbar").get_file_name({})
	if vim.fn.bufname("%") == "" then
		return ""
	end
	if include_path == false then
		return file_name
	end
	-- Else if include path: ./lsp/saga.lua -> lsp > saga.lua
	local sep = vim.loop.os_uname().sysname == "Windows" and "\\" or "/"
	local path_list = vim.split(string.gsub(vim.fn.expand("%:~:.:h"), "%%", ""), sep)
	local file_path = ""
	for _, cur in ipairs(path_list) do
		file_path = (cur == "." or cur == "~") and "" or file_path .. cur .. " " .. "%#LspSagaWinbarSep#>%*" .. " %*"
	end
	return file_path .. file_name
end

local function config_winbar_or_statusline()
	local exclude = {
		["terminal"] = true,
		["toggleterm"] = true,
		["prompt"] = true,
		["NvimTree"] = true,
		["help"] = true,
	} -- Ignore float windows and exclude filetype
	if vim.api.nvim_win_get_config(0).zindex or exclude[vim.bo.filetype] then
		vim.wo.winbar = ""
	else
		local ok, lspsaga = pcall(require, "lspsaga.symbolwinbar")
		local sym
		if ok then
			sym = lspsaga.get_symbol_node()
		end
		local win_val = ""
		win_val = get_file_name(true) -- set to true to include path
		if sym ~= nil then
			win_val = win_val .. sym
		end
		vim.wo.winbar = win_val
	end
end

local events = { "BufEnter", "BufWinEnter", "CursorMoved" }

vim.api.nvim_create_autocmd(events, {
	pattern = "*",
	callback = function()
		config_winbar_or_statusline()
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "LspsagaUpdateSymbol",
	callback = function()
		config_winbar_or_statusline()
	end,
})

local opts = { noremap = true, silent = true }
-- vim.keymap.set("n", "gl", "<cmd>Lspsaga show_line_diagnostics<cr>", opts)
-- vim.keymap.set("n", "gcl", "<cmd>Lspsaga show_cursor_diagnostics<cr>", opts)
vim.keymap.set("n", "<C-n>", "<cmd>Lspsaga diagnostic_jump_next<cr>", opts)
vim.keymap.set("n", "<C-p>", "<cmd>Lspsaga diagnostic_jump_prev<cr>", opts)
vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<cr>", opts)
vim.keymap.set("n", "gf", "<cmd>Lspsaga lsp_finder<cr>", opts)
vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>", opts)
vim.keymap.set("n", "<F2>", "<cmd>Lspsaga rename<cr>", { silent = true })
-- NOTE: lsp rename can only be used if the it's recongnized by lsp; otherwise use Spectre.nvim

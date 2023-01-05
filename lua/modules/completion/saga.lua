local icons = {
	diagnostics = require("modules.ui.icons").get("diagnostics", true),
	kind = require("modules.ui.icons").get("kind", true),
	type = require("modules.ui.icons").get("type", true),
	ui = require("modules.ui.icons").get("ui", true),
}

local function set_sidebar_icons()
	-- Set icons for sidebar.
	local diagnostic_icons = {
		Error = icons.diagnostics.Error_alt,
		Warn = icons.diagnostics.Warning_alt,
		Info = icons.diagnostics.Information_alt,
		Hint = icons.diagnostics.Hint_alt,
	}
	for type, icon in pairs(diagnostic_icons) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl })
	end
end

local function get_palette()
	if vim.g.colors_name == "catppuccin" then
		-- If the colorscheme is catppuccin then use the palette.
		return require("catppuccin.palettes").get_palette()
	else
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
end

set_sidebar_icons()

local colors = get_palette()

require("lspsaga").init_lsp_saga({
	-- keybinds for navigation in lspsaga window
	move_in_saga = { prev = "<C-k>", next = "<C-j>" },
	-- use enter to open file with finder
	-- NOTE: <C-o> go to older position in jump list
	-- NOTE: <C-i> go to newer position in jump list
	finder_action_keys = {
		open = "<CR>",
	},
	-- use enter to open file with definition preview
	definition_action_keys = {
		edit = "<CR>",
	},
	border_style = "bold",
	code_action_icon = icons.ui.Lightbulb,
	code_action_lightbulb = {
		enable = false,
		enable_in_insert = true,
		cache_code_action = true,
		sign = true,
		update_time = 150,
		sign_priority = 20,
		virtual_text = true,
	},
	diagnostic_header = {
		icons.diagnostics.Error_alt,
		icons.diagnostics.Warning_alt,
		icons.diagnostics.Information_alt,
		icons.diagnostics.Hint_alt,
	},
	custom_kind = {
		Class = { icons.kind.Class, colors.yellow },
		Constant = { icons.kind.Constant, colors.peach },
		Constructor = { icons.kind.Constructor, colors.sapphire },
		Enum = { icons.kind.Enum, colors.yellow },
		EnumMember = { icons.kind.EnumMember, colors.teal },
		Event = { icons.kind.Event, colors.yellow },
		Field = { icons.kind.Field, colors.teal },
		Function = { icons.kind.Function, colors.blue },
		Interface = { icons.kind.Interface, colors.yellow },
		Key = { icons.kind.Keyword, colors.red },
		Method = { icons.kind.Method, colors.blue },
		Module = { icons.kind.Module, colors.blue },
		Namespace = { icons.kind.Namespace, colors.blue },
		Operator = { icons.kind.Operator, colors.sky },
		Package = { icons.kind.Package, colors.blue },
		Property = { icons.kind.Property, colors.teal },
		Struct = { icons.kind.Struct, colors.yellow },
		TypeParameter = { icons.kind.TypeParameter, colors.maroon },
		Variable = { icons.kind.Variable, colors.peach },
		-- Type
		Array = { icons.type.Array, colors.peach },
		Boolean = { icons.type.Boolean, colors.peach },
		Null = { icons.type.Null, colors.yellow },
		Number = { icons.kind.Number, colors.peach },
		Object = { icons.type.Object, colors.yellow },
		String = { icons.type.String, colors.green },
		-- ccls-specific iconss.
		TypeAlias = { icons.kind.TypeAlias, colors.green },
		Parameter = { icons.kind.Parameter, colors.blue },
		StaticMethod = { icons.kind.StaticMethod, colors.peach },
		Macro = { icons.kind.Macro, colors.red },
	},
	symbol_in_winbar = {
		enable = true,
		in_custom = true,
		separator = " " .. icons.ui.DoubleSeparator,
		show_file = false,
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
					print("symbol_winbar")
				end
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

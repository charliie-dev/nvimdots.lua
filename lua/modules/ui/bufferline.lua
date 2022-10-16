vim.api.nvim_set_hl(0, "BLIndicatorIcon", { fg = "#E8AB53", bg = "NONE" })
local icons = { ui = require("modules.ui.icons").get("ui") }

require("bufferline").setup({
	options = {
		mode = "buffers",
		numbers = "none",
		close_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
		right_mouse_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
		left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
		middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"

		indicator = {
			-- icon = "▎",
			icon = "%#BLIndicatorIcon#" .. " " .. icons.ui.Indicator .. " ",
			style = "icon",
		},
		buffer_close_icon = icons.ui.Close,
		modified_icon = icons.ui.Modified,
		close_icon = icons.ui.Close_alt,
		left_trunc_marker = icons.ui.Left,
		right_trunc_marker = icons.ui.Right,

		max_name_length = 14,
		max_prefix_length = 13, -- prefix used when a buffer is de-duplicated
		tab_size = 20,
		diagnostics = "nvim_lsp", -- | "nvim_lsp" | "coc",
		diagnostics_update_in_insert = false,
		diagnostics_indicator = function(count)
			return "(" .. count .. ")"
		end,

		offsets = {
			{
				filetype = "NvimTree",
				text = "File Explorer",
				text_align = "center",
				highlight = "Directory",
				separator = true,
			},
			{
				filetype = "undotree",
				text = "Undo Tree",
				text_align = "center",
				highlight = "Directory",
				separator = true,
			},
			{
				filetype = "neo-tree",
				text = "Neo Tree",
				text_align = "center",
				highlight = "Directory",
				separator = true,
			},
		},
		color_icons = true,
		show_buffer_icons = true,
		show_buffer_close_icons = true,
		show_buffer_default_icon = true,
		show_close_icon = true,
		show_tab_indicators = true,
		persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
		-- can also be a table containing 2 custom separators
		-- [focused and unfocused]. eg: { '|', '|' }
		separator_style = "thin", -- | "thick" | "thin" | { 'any', 'any' },
		enforce_regular_tabs = true,
		always_show_bufferline = true,
		-- sort_by = 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b)
		--   -- add custom logic
		--   return buffer_a.modified > buffer_b.modified
		-- end
	},
})

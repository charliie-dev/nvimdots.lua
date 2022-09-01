local status, bufferline = pcall(require, "bufferline")
if not status then
	return
end

local icon = require("icons")

bufferline.setup({
	options = {
    mode = "buffers",
    numbers = "none",
		close_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
		right_mouse_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
		left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
		middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"

		indicator = {
      -- icon = "▎",
      icon = " ",
      style = "icon",
    },
		buffer_close_icon = "",
		modified_icon = "●",
		close_icon = "",
		left_trunc_marker = "",
		right_trunc_marker = "",

		max_name_length = 18,
		max_prefix_length = 18, -- prefix used when a buffer is de-duplicated
		tab_size = 18,
		diagnostics = false, -- | "nvim_lsp" | "coc",
		diagnostics_update_in_insert = false,

		offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        text_align ="center",
        highlight = "Directory",
        separator = true
      }
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

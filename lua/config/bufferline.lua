local status, bufferline = pcall(require, "bufferline")
if not status then
	return
end

local icon = require("icons")

bufferline.setup({
	options = {
		numbers = "none", -- | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
		close_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
		right_mouse_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
		left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
		middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
		-- NOTE: this plugin is designed with this icon in mind,
		-- and so changing this is NOT recommended, this is intended
		-- as an escape hatch for people who cannot bear it for whatever reason
		-- indicator_icon = "▎",
		indicator_icon = "  ",
		buffer_close_icon = "",
		-- buffer_close_icon = '',
		modified_icon = "●",
		close_icon = "",
		left_trunc_marker = "",
		right_trunc_marker = "",
		--- name_formatter can be used to change the buffer's label in the bufferline.
		--- Please note some names can/will break the
		--- bufferline so use this at your discretion knowing that it has
		--- some limitations that will *NOT* be fixed.
		name_formatter = function(buf)  -- buf contains a "name", "path" and "bufnr"
		  -- remove extension from markdown files for example
		  if buf.name:match('%.md') then
		    return vim.fn.fnamemodify(buf.name, ':t:r')
		  end
		end,
		max_name_length = 18,
		max_prefix_length = 18, -- prefix used when a buffer is de-duplicated
		tab_size = 21,
		diagnostics = "nvim_lsp", -- | "nvim_lsp" | "coc",
		diagnostics_update_in_insert = false,
    -- diagnostics_indicator = function(count, level, diagnostics_dict, context)
    diagnostics_indicator = function(_, _, diagnostics_dict, _)
      local s = " "
      for e, _ in pairs(diagnostics_dict) do
        local sym = e == "error" and icon.diagnostics.Error
          or (e == "warning" and icon.diagnostics.Warning)
          or (e == "hint" and icon.diagnostics.Hint)
          or (e == "info" and icon.diagnostics.Information)
        s = s .. sym .. " "
      end
      return s
    end,
		-- NOTE: this will be called a lot so don't do any heavy processing here
		-- custom_filter = function(buf_number)
		--   -- filter out filetypes you don't want to see
		--   if vim.bo[buf_number].filetype ~= "<i-dont-want-to-see-this>" then
		--     return true
		--   end
		--   -- filter out by buffer name
		--   if vim.fn.bufname(buf_number) ~= "<buffer-name-I-dont-want>" then
		--     return true
		--   end
		--   -- filter out based on arbitrary rules
		--   -- e.g. filter out vim wiki buffer from tabline in your work repo
		--   if vim.fn.getcwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
		--     return true
		--   end
		-- end,
		offsets = { { filetype = "NvimTree", text = "File Explorer",  text_align ="center", padding = 1 } },
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
  custom_areas = {
    right = function()
      local result = {}
      local seve = vim.diagnostic.severity
      local error = #vim.diagnostic.get(0, {severity = seve.ERROR})
      local warning = #vim.diagnostic.get(0, {severity = seve.WARN})
      local info = #vim.diagnostic.get(0, {severity = seve.INFO})
      local hint = #vim.diagnostic.get(0, {severity = seve.HINT})

      if error ~= 0 then
        table.insert(result, {text = "  " .. error, guifg = "#EC5241"})
      end

      if warning ~= 0 then
        table.insert(result, {text = "  " .. warning, guifg = "#EFB839"})
      end

      if hint ~= 0 then
        table.insert(result, {text = "  " .. hint, guifg = "#A3BA5E"})
      end

      if info ~= 0 then
        table.insert(result, {text = "  " .. info, guifg = "#7EA9A7"})
      end
      return result
    end,
  },
	-- highlights = {
	-- 	fill = {
	-- 		guifg = { attribute = "fg", highlight = "#ff0000" },
	-- 		guibg = { attribute = "bg", highlight = "TabLine" },
	-- 	},
	-- 	background = {
	-- 		guifg = { attribute = "fg", highlight = "TabLine" },
	-- 		guibg = { attribute = "bg", highlight = "TabLine" },
	-- 	},
	--
	-- 	-- buffer_selected = {
	-- 	--   guifg = {attribute='fg',highlight='#ff0000'},
	-- 	--   guibg = {attribute='bg',highlight='#0000ff'},
	-- 	--   gui = 'none'
	-- 	--   },
	-- 	buffer_visible = {
	-- 		guifg = { attribute = "fg", highlight = "TabLine" },
	-- 		guibg = { attribute = "bg", highlight = "TabLine" },
	-- 	},
	--
	-- 	close_button = {
	-- 		guifg = { attribute = "fg", highlight = "TabLine" },
	-- 		guibg = { attribute = "bg", highlight = "TabLine" },
	-- 	},
	-- 	close_button_visible = {
	-- 		guifg = { attribute = "fg", highlight = "TabLine" },
	-- 		guibg = { attribute = "bg", highlight = "TabLine" },
	-- 	},
	-- 	-- close_button_selected = {
	-- 	--   guifg = {attribute='fg',highlight='TabLineSel'},
	-- 	--   guibg ={attribute='bg',highlight='TabLineSel'}
	-- 	--   },
	--
	-- 	tab_selected = {
	-- 		guifg = { attribute = "fg", highlight = "Normal" },
	-- 		guibg = { attribute = "bg", highlight = "Normal" },
	-- 	},
	-- 	tab = {
	-- 		guifg = { attribute = "fg", highlight = "TabLine" },
	-- 		guibg = { attribute = "bg", highlight = "TabLine" },
	-- 	},
	-- 	tab_close = {
	-- 		-- guifg = {attribute='fg',highlight='LspDiagnosticsDefaultError'},
	-- 		guifg = { attribute = "fg", highlight = "TabLineSel" },
	-- 		guibg = { attribute = "bg", highlight = "Normal" },
	-- 	},
	--
	-- 	duplicate_selected = {
	-- 		guifg = { attribute = "fg", highlight = "TabLineSel" },
	-- 		guibg = { attribute = "bg", highlight = "TabLineSel" },
	-- 		gui = "italic",
	-- 	},
	-- 	duplicate_visible = {
	-- 		guifg = { attribute = "fg", highlight = "TabLine" },
	-- 		guibg = { attribute = "bg", highlight = "TabLine" },
	-- 		gui = "italic",
	-- 	},
	-- 	duplicate = {
	-- 		guifg = { attribute = "fg", highlight = "TabLine" },
	-- 		guibg = { attribute = "bg", highlight = "TabLine" },
	-- 		gui = "italic",
	-- 	},
	--
	-- 	modified = {
	-- 		guifg = { attribute = "fg", highlight = "TabLine" },
	-- 		guibg = { attribute = "bg", highlight = "TabLine" },
	-- 	},
	-- 	modified_selected = {
	-- 		guifg = { attribute = "fg", highlight = "Normal" },
	-- 		guibg = { attribute = "bg", highlight = "Normal" },
	-- 	},
	-- 	modified_visible = {
	-- 		guifg = { attribute = "fg", highlight = "TabLine" },
	-- 		guibg = { attribute = "bg", highlight = "TabLine" },
	-- 	},
	--
	-- 	separator = {
	-- 		guifg = { attribute = "bg", highlight = "TabLine" },
	-- 		guibg = { attribute = "bg", highlight = "TabLine" },
	-- 	},
	-- 	separator_selected = {
	-- 		guifg = { attribute = "bg", highlight = "Normal" },
	-- 		guibg = { attribute = "bg", highlight = "Normal" },
	-- 	},
	-- 	-- separator_visible = {
	-- 	--   guifg = {attribute='bg',highlight='TabLine'},
	-- 	--   guibg = {attribute='bg',highlight='TabLine'}
	-- 	--   },
	-- 	indicator_selected = {
	-- 		guifg = { attribute = "fg", highlight = "LspDiagnosticsDefaultHint" },
	-- 		guibg = { attribute = "bg", highlight = "Normal" },
	-- 	},
	-- },
})

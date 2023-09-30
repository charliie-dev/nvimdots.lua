local bind = require("keymap.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_callback = bind.map_callback
local et = bind.escape_termcode

local plug_map = {
	-- Plugin: accelerate-jk
	["n|j"] = map_callback(function()
		return et("<Plug>(accelerated_jk_gj)")
	end):with_expr(),
	["n|k"] = map_callback(function()
		return et("<Plug>(accelerated_jk_gk)")
	end):with_expr(),

	-- Plugin persisted.nvim
	["n|<leader>ss"] = map_cu("SessionSave"):with_noremap():with_silent():with_desc("session: Save"),
	["n|<leader>sl"] = map_cu("SessionLoad"):with_noremap():with_silent():with_desc("session: Load current"),
	["n|<leader>sd"] = map_cu("SessionDelete"):with_noremap():with_silent():with_desc("session: Delete"),

	-- Plugin: nvim-bufdel
	["n|<F4>"] = map_cr("BufDel"):with_noremap():with_silent():with_desc("buffer: Close current"),

	-- Plugin: comment-frame
	["n|<leader>cf"] = map_callback(function()
		require("nvim-comment-frame").add_comment()
	end):with_desc("edit: Add comment box around the texts"),
	["n|<leader>cF"] = map_callback(function()
		require("nvim-comment-frame").add_multiline_comment()
	end):with_desc("edit: Add comment box around multi lines of texts"),

	-- Plugin: comment.nvim
	["n|gcc"] = map_callback(function()
			return vim.v.count == 0 and et("<Plug>(comment_toggle_linewise_current)")
				or et("<Plug>(comment_toggle_linewise_count)")
		end)
		:with_silent()
		:with_noremap()
		:with_expr()
		:with_desc("edit: Toggle comment for line"),
	["n|gbc"] = map_callback(function()
			return vim.v.count == 0 and et("<Plug>(comment_toggle_blockwise_current)")
				or et("<Plug>(comment_toggle_blockwise_count)")
		end)
		:with_silent()
		:with_noremap()
		:with_expr()
		:with_desc("edit: Toggle comment for block"),
	["n|gc"] = map_cmd("<Plug>(comment_toggle_linewise)")
		:with_silent()
		:with_noremap()
		:with_desc("edit: Toggle comment for line with operator"),
	["n|gb"] = map_cmd("<Plug>(comment_toggle_blockwise)")
		:with_silent()
		:with_noremap()
		:with_desc("edit: Toggle comment for block with operator"),
	["x|gc"] = map_cmd("<Plug>(comment_toggle_linewise_visual)")
		:with_silent()
		:with_noremap()
		:with_desc("edit: Toggle comment for line with selection"),
	["x|gb"] = map_cmd("<Plug>(comment_toggle_blockwise_visual)")
		:with_silent()
		:with_noremap()
		:with_desc("edit: Toggle comment for block with selection"),

	-- Plugin: diffview
	["n|<leader>dv"] = map_cr("DiffviewOpen"):with_silent():with_noremap():with_desc("git: Show diff"),
	["n|<leader><leader>dv"] = map_cr("DiffviewClose"):with_silent():with_noremap():with_desc("git: Close diff"),

	-- Plugin: vim-easy-align
	["nx|gea"] = map_cr("EasyAlign"):with_desc("edit: Align with delimiter"),

	-- Plugin: leap
	-- `f` motion
	["n|f"] = map_callback(function()
			return et("<Plug>(leap-forward-to)")
		end)
		:with_expr()
		:with_desc("leapn: Jump to character"),
	["x|f"] = map_callback(function()
			return et("<Plug>(leap-forward-to)")
		end)
		:with_expr()
		:with_desc("leapx: Visual select to character"),
	["o|f"] = map_callback(function()
			return et("<Plug>(leap-forward-to)")
		end)
		:with_expr()
		:with_desc("leapo: Operatate to character"),
	-- `F` motion
	["n|F"] = map_callback(function()
			return et("<Plug>(leap-backward-to)")
		end)
		:with_expr()
		:with_desc("leapn: Jump backward to character"),
	["x|F"] = map_callback(function()
			return et("<Plug>(leap-backward-to)")
		end)
		:with_expr()
		:with_desc("leapx: Visual select backward to character"),
	["o|F"] = map_callback(function()
			return et("<Plug>(leap-backward-to)")
		end)
		:with_expr()
		:with_desc("leapo: Operatate backward to character"),
	-- `t` motion
	["n|t"] = map_callback(function()
			return et("<Plug>(leap-forward-till)")
		end)
		:with_expr()
		:with_desc("leapn: Jump till character"),
	["x|t"] = map_callback(function()
			return et("<Plug>(leap-forward-till)")
		end)
		:with_expr()
		:with_desc("leapx: Visual select till character"),
	["o|t"] = map_callback(function()
			return et("<Plug>(leap-forward-till)")
		end)
		:with_expr()
		:with_desc("leapo: Operatate till character"),
	-- `T` motion
	["n|T"] = map_callback(function()
			return et("<Plug>(leap-backward-till)")
		end)
		:with_expr()
		:with_desc("leapn: Jump backward till character"),
	["x|T"] = map_callback(function()
			return et("<Plug>(leap-backward-till)")
		end)
		:with_expr()
		:with_desc("leapx: Visual select backward till character"),
	["o|T"] = map_callback(function()
			return et("<Plug>(leap-backward-till)")
		end)
		:with_expr()
		:with_desc("leapo: Operatate backward till character"),
	["n|gt"] = map_callback(function()
			return et("<Plug>(leap-from-window)")
		end)
		:with_expr()
		:with_desc("leapn: Jump to character across windows"),

	--- Plugin: nvim-surround
	["n|ys"] = map_callback(function()
			return et("<Plug>(nvim-surround-normal)")
		end)
		:with_expr()
		:with_desc("edit: Add a surrounding pair around a motion"),
	["n|yss"] = map_callback(function()
			return et("<Plug>(nvim-surround-normal-cur")
		end)
		:with_expr()
		:with_desc("edit: Add a surrounding pair around current line"),
	["n|yS"] = map_callback(function()
			return et("<Plug>(nvim-surround-normal-line)")
		end)
		:with_expr()
		:with_desc("edit: Add a surrounding pair around a motion, on new lines"),
	["n|ySS"] = map_callback(function()
			return et("<Plug>(nvim-surround-normal-cur-line)")
		end)
		:with_expr()
		:with_desc("edit: Add a surrounding pair around the current line, on new lines"),
	["x|ys"] = map_callback(function()
			return et("<Plug>(nvim-surround-visual")
		end)
		:with_expr()
		:with_desc("edit: Add a surrounding pair around a visual selection"),
	["x|yS"] = map_callback(function()
			return et("<Plug>(nvim-surround-visual-line")
		end)
		:with_expr()
		:with_desc("edit: Add a surrounding pair around a visual selection, on new lines"),
	["n|ds"] = map_callback(function()
			return et("<Plug>(nvim-surround-delete")
		end)
		:with_expr()
		:with_desc("edit: Delete a surrounding pair"),
	["n|cs"] = map_callback(function()
			return et("<Plug>(nvim-surround-change")
		end)
		:with_expr()
		:with_desc("edit: Change a surrounding pair"),

	-- Plugin: tabout
	["i|<A-l>"] = map_cmd("<Plug>(TaboutMulti)"):with_silent():with_noremap():with_desc("edit: Goto end of pair"),
	["i|<A-h>"] = map_cmd("<Plug>(TaboutBackMulti)"):with_silent():with_noremap():with_desc("edit: Goto begin of pair"),

	-- Plugin suda.vim
	["n|<A-s>"] = map_cu("SudaWrite"):with_silent():with_noremap():with_desc("editn: Save file using sudo"),
}

bind.nvim_load_mapping(plug_map)

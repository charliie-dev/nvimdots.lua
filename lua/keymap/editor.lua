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

	-- Plugin: nvim-bufdel
	["n|<F4>"] = map_cr("BufDel"):with_noremap():with_silent():with_desc("buffer: Close current"),

	-- Plugin: comment-frame
	["n|<leader>cf"] = map_callback(function()
		require("nvim-comment-frame").add_comment()
	end):with_desc("editn: Add comment box around the texts"),
	["n|<leader>cF"] = map_callback(function()
		require("nvim-comment-frame").add_multiline_comment()
	end):with_desc("editn: Add comment box around multi lines of texts"),

	-- Plugin: comment.nvim
	["n|gcc"] = map_callback(function()
			return vim.v.count == 0 and et("<Plug>(comment_toggle_linewise_current)")
				or et("<Plug>(comment_toggle_linewise_count)")
		end)
		:with_silent()
		:with_noremap()
		:with_expr()
		:with_desc("editn: Toggle comment for line"),
	["n|gbc"] = map_callback(function()
			return vim.v.count == 0 and et("<Plug>(comment_toggle_blockwise_current)")
				or et("<Plug>(comment_toggle_blockwise_count)")
		end)
		:with_silent()
		:with_noremap()
		:with_expr()
		:with_desc("editn: Toggle comment for block"),
	["n|gc"] = map_cmd("<Plug>(comment_toggle_linewise)")
		:with_silent()
		:with_noremap()
		:with_desc("editn: Toggle comment for line with operator"),
	["n|gb"] = map_cmd("<Plug>(comment_toggle_blockwise)")
		:with_silent()
		:with_noremap()
		:with_desc("editn: Toggle comment for block with operator"),
	["x|gc"] = map_cmd("<Plug>(comment_toggle_linewise_visual)")
		:with_silent()
		:with_noremap()
		:with_desc("editx: Toggle comment for line with selection"),
	["x|gb"] = map_cmd("<Plug>(comment_toggle_blockwise_visual)")
		:with_silent()
		:with_noremap()
		:with_desc("editx: Toggle comment for block with selection"),

	-- Plugin: diffview
	["n|<leader>dv"] = map_cr("DiffviewOpen"):with_silent():with_noremap():with_desc("git: Show diff"),
	["n|<leader><leader>dv"] = map_cr("DiffviewClose"):with_silent():with_noremap():with_desc("git: Close diff"),

	-- Plugin: vim-easy-align
	["n|gea"] = map_callback(function()
			return et("<Plug>(EasyAlign)")
		end)
		:with_expr()
		:with_desc("editn: Align with delimiter"),
	["x|gea"] = map_callback(function()
			return et("<Plug>(EasyAlign)")
		end)
		:with_expr()
		:with_desc("editx: Align with delimiter"),

	-- Plugin: leap
	-- "s/S", "f/F", "t/T" to use leap TODO:

	-- Plugin: search-replace
	-- SearchReplaceSingleBuffer
	["n|<leader>rs"] = map_cu("SearchReplaceSingleBufferSelections")
		:with_noremap()
		:with_desc("editn: Show search-repacle menu in current buffer"),
	["n|<leader>ro"] = map_cu("SearchReplaceSingleBufferOpen")
		:with_noremap()
		:with_desc("editn: Search-repacle in current buffer"),
	["n|<leader>rw"] = map_cu("SearchReplaceSingleBufferCWord")
		:with_noremap()
		:with_desc("editn: Search-repacle current buffer CWord"),
	["n|<leader>rW"] = map_cu("SearchReplaceSingleBufferCWORD")
		:with_noremap()
		:with_desc("editn: Search-repacle current buffer CWORD"),
	["n|<leader>re"] = map_cu("SearchReplaceSingleBufferCExpr")
		:with_noremap()
		:with_desc("editn: Search-repacle current buffer CExpr"),
	["n|<leader>rf"] = map_cu("SearchReplaceSingleBufferCFile")
		:with_noremap()
		:with_desc("editn: Search-repacle current buffer CFile"),
	-- SearchReplaceMultiBuffer
	["n|<leader>rbs"] = map_cu("SearchReplaceMultiBufferSelections")
		:with_noremap()
		:with_desc("editn: Show search-repacle menu for multi buffer"),
	["n|<leader>rbo"] = map_cu("SearchReplaceMultiBufferOpen")
		:with_noremap()
		:with_desc("editn: Search-repacle in multi buffers"),
	["n|<leader>rbw"] = map_cu("SearchReplaceMultiBufferCWord")
		:with_noremap()
		:with_desc("editn: Search-repacle multi buffers CWord"),
	["n|<leader>rbW"] = map_cu("SearchReplaceMultiBufferCWORD")
		:with_noremap()
		:with_desc("editn: Search-repacle multi buffers CWORD"),
	["n|<leader>rbe"] = map_cu("SearchReplaceMultiBufferCExpr")
		:with_noremap()
		:with_desc("editn: Search-repacle multi buffers CExpr"),
	["n|<leader>rbf"] = map_cu("SearchReplaceMultiBufferCFile")
		:with_noremap()
		:with_desc("editn: Search-repacle multi buffers CFile"),
	-- Visual Mode
	["v|<C-r>"] = map_cu("SearchReplaceSingleBufferVisualSelection")
		:with_noremap()
		:with_desc("editv: Search-replace with selection within one line"),
	["v|<C-w>"] = map_cu("SearchReplaceWithinVisualSelectionCWord")
		:with_noremap()
		:with_desc("editv: Search-replace with selection within one line CWord"),

	--- Plugin: nvim-surround TODO:
	-- keymaps = {
	--     insert = "<C-g>z",
	--     insert_line = "<C-g>Z",
	--     normal = "gz",
	--     normal_cur = "gZ",
	--     normal_line = "gzz",
	--     normal_cur_line = "gZZ",
	--     visual = "gz",
	--     visual_line = "gZ",
	--     delete = "gzd",
	--     change = "gzc",
	-- },

	--- various-textobjs TODO:
	-- select around same indent level
	-- keymap("o", "aI", "<cmd>lua require('various-textobjs').indentation(false, false)<cr>", opts)
	-- keymap("x", "aI", "<cmd>lua require('various-textobjs').indentation(false, false)<cr>", opts)
	-- -- select inside same indent level
	-- keymap("o", "iI", "<cmd>lua require('various-textobjs').indentation(true, true)<cr>", opts)
	-- keymap("x", "iI", "<cmd>lua require('various-textobjs').indentation(true, true)<cr>", opts)

	-- -- select around value of key-value pair, including trailing commas or semicolons
	-- keymap("o", "av", "<cmd>lua require('various-textobjs').value(false)<cr>", opts)
	-- keymap("x", "av", "<cmd>lua require('various-textobjs').value(false)<cr>", opts)
	-- -- select inside value of key-value pair, excluding trailing commas or semicolons
	-- keymap("o", "iv", "<cmd>lua require('various-textobjs').value(true)<cr>", opts)
	-- keymap("x", "iv", "<cmd>lua require('various-textobjs').value(true)<cr>", opts)

	-- -- select around number, including signs & decimal point
	-- keymap("o", "an", "<cmd>lua require('various-textobjs').number(false)<cr>", opts)
	-- keymap("x", "an", "<cmd>lua require('various-textobjs').number(false)<cr>", opts)
	-- -- select pure number, excluding signs & decimal point
	-- keymap("o", "in", "<cmd>lua require('various-textobjs').number(true)<cr>", opts)
	-- keymap("x", "in", "<cmd>lua require('various-textobjs').number(true)<cr>", opts)

	-- -- select LSP diagnostic(require built-in LSP)
	-- keymap("o", "!", "<cmd>lua require('various-textobjs').diagnostic()<cr>", opts)
	-- keymap("x", "!", "<cmd>lua require('various-textobjs').diagnostic()<cr>", opts)

	-- -- select entire mdlink, [title](url), md only
	-- keymap("o", "al", "<cmd>lua require('various-textobjs').mdlink(false)<cr>", opts)
	-- keymap("x", "al", "<cmd>lua require('various-textobjs').mdlink(false)<cr>", opts)
	-- -- select mdlink title, md only
	-- keymap("o", "il", "<cmd>lua require('various-textobjs').mdlink(true)<cr>", opts)
	-- keymap("x", "il", "<cmd>lua require('various-textobjs').mdlink(true)<cr>", opts)

	-- -- select arround mdFencedCodeBlock, including the enclosing backticks, md only
	-- keymap("o", "aC", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(false)<cr>", opts)
	-- keymap("x", "aC", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(false)<cr>", opts)
	-- -- select inside mdFencedCodeBlock, excluding the enclosing backticks, md only
	-- keymap("o", "iC", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(true)<cr>", opts)
	-- keymap("x", "iC", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(true)<cr>", opts)

	-- -- select arround doubleSquareBrackets([[]]), including the four square brackets(lua, shell, neorg, md)
	-- keymap("o", "aC", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(false)<cr>", opts)
	-- keymap("x", "aC", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(false)<cr>", opts)
	-- -- select inside doubleSquareBrackets([[]]), excluding the four square brackets(lua, shell, neorg, md)
	-- keymap("o", "iC", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(true)<cr>", opts)
	-- keymap("x", "iC", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(true)<cr>", opts)

	-- -- select column down until indent or shorter line. Accepts `{count}` for multi-columns
	-- keymap("o", "|", "<cmd>lua require('various-textobjs').column()<cr>", opts)
	-- keymap("x", "|", "<cmd>lua require('various-textobjs').column()<cr>", opts)
	-- keymap("x", "|", "<cmd>lua require('various_textobjs').column()<cr>", opts)

	-- -- select the rest of the Paragraph, like `}`, but linewise
	-- keymap("o", "r", "<cmd>lua require('various-textobjs').restOfParagraph()<cr>", opts)
	-- keymap("x", "r", "<cmd>lua require('various-textobjs').restOfParagraph()<cr>", opts)

	-- -- select subword, but never treating `-`, `_` or `.` as word delimiters
	-- keymap("o", "aS", "<cmd>lua require('various-textobjs').subword(false)<cr>", opts)
	-- keymap("x", "aS", "<cmd>lua require('various-textobjs').subword(false)<cr>", opts)
	-- -- --
	-- keymap("o", "iS", "<cmd>lua require('various-textobjs').subword(true)<cr>", opts)
	-- keymap("x", "iS", "<cmd>lua require('various-textobjs').subword(true)<cr>", opts)

	--- Plugin: treesj TODO:
	-- "<Space>m" to toggle split/join

	--- Plugin: syntax-tree-surfer TODO:
	-- Visual Selection from Normal Mode
	-- keymap("n", "vx", "<cmd>STSSelectMasterNode<cr>", opts)
	-- keymap("n", "vn", "<cmd>STSSelectCurrentNode<cr>", opts)

	--	-- Targeted Jump with virtual_text
	--	local sts = require("syntax-tree-surfer")
	--	local keymap = vim.keymap.set
	--	local opts = { noremap = true, silent = true, nowait = true }
	--	keymap("n", "gv", function() -- only jump to variable_declarations, can only jump within visible window
	--		sts.targeted_jump({ "variable_declaration" })
	--	end, opts)
	--	keymap("n", "gfu", function() -- only jump to functions
	--		sts.targeted_jump({ "function", "arrrow_function", "function_definition" })
	--		--> In this example, the Lua language schema uses "function",
	--		--  when the Python language uses "function_definition"
	--		--  we include both, so this keymap will work on both languages
	--	end, opts)
	--	keymap("n", "gif", function() -- only jump to if_statements
	--		sts.targeted_jump({ "if_statement" })
	--	end, opts)
	--	keymap("n", "gfo", function() -- only jump to for_statements
	--		sts.targeted_jump({ "for_statement" })
	--	end, opts)
	--	keymap("n", "gj", function() -- jump to all that you specify
	--		sts.targeted_jump({
	--			"function",
	--			"if_statement",
	--			"else_clause",
	--			"else_statement",
	--			"elseif_statement",
	--			"for_statement",
	--			"while_statement",
	--			"switch_statement",
	--		})
	--	end, opts)

	-- Select Nodes in Visual Mode
	-- keymap("x", "[", "<cmd>STSSelectPrevSiblingNode<cr>", opts)
	-- keymap("x", "]", "<cmd>STSSelectNextSiblingNode<cr>", opts)
	-- keymap("x", "=", "<cmd>STSSelectParentNode<cr>", opts)
	-- keymap("x", "-", "<cmd>STSSelectChildNode<cr>", opts)

	-- Targeted Jump with virtual_text, placed in tree-surfer.lua
	-- "gv", jump to variable_declarations(only within visible window)
	-- "gfu", jump to functions
	-- "gif", jump to if-statements
	-- "gfo", jump to for-statements
	-- "gj", jump to certain nodes

	-- Plugin: tabout
	["i|<A-l>"] = map_cmd("<Plug>(TaboutMulti)"):with_silent():with_noremap():with_desc("editi: Goto end of pair"),
	["i|<A-h>"] = map_cmd("<Plug>(TaboutBackMulti)")
		:with_silent()
		:with_noremap()
		:with_desc("editi: Goto begin of pair"),
}

bind.nvim_load_mapping(plug_map)

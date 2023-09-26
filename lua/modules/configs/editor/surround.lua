return function()
	-- repo readme
	-- The three "core" operations of add/delete/change can be done
	-- with the keymaps ys{motion}{char}, ds{char}, and cs{target}{replacement},
	-- respectively. For the following examples, * will denote the cursor position:

	-- Old text                    Command         New text
	--------------------------------------------------------------------------------
	-- surr*ound_words             ysiw)           (surround_words)
	-- *make strings               ys$"            "make strings"
	-- [delete ar*ound me!]        ds]             delete around me!
	-- remove <b>HTML t*ags</b>    dst             remove HTML tags
	-- 'change quot*es'            cs'"            "change quotes"
	-- <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
	-- delete(functi*on calls)     dsf             function calls
	-- NOTE: this config doesn't use the default keymaps

	require("modules.utils").load_plugin("nvim-surround", {
		move_cursor = "begin", -- set to fasle to disable this
		keymaps = {
			insert = nil,
			insert_line = nil,
			normal = nil,
			normal_cur = nil,
			normal_line = nil,
			normal_cur_line = nil,
			visual = nil,
			visual_line = nil,
			delete = nil,
			change = nil,
		},
		aliases = {
			["a"] = ">",
			["b"] = ")",
			["B"] = "}",
			["r"] = "]",
			["q"] = { '"', "'", "`" },
			["s"] = { "}", "]", ")", ">", '"', "'", "`" },
			-- ["t"] = html tag
			-- ["f"] = function calls
		},
	})
end

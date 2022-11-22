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

-- HACK: play nice with leap.nvim
-- HACK: https://github.com/ggandor/leap.nvim/discussions/59#discussioncomment-3943323
require("nvim-surround").setup({
	move_cursor = "begin", -- set to fasle to disable this
	keymaps = {
		insert = "<C-g>z",
		insert_line = "<C-g>Z",
		normal = "gz",
		normal_cur = "gZ",
		normal_line = "gzz",
		normal_cur_line = "gZZ",
		visual = "gz",
		visual_line = "gZ",
		delete = "gzd",
		change = "gzc",
	},
})

-- aliases = {
--     ["a"] = ">",
--     ["b"] = ")",
--     ["B"] = "}",
--     ["r"] = "]",
--     ["q"] = { '"', "'", "`" },
--     ["s"] = { "}", "]", ")", ">", '"', "'", "`" },

-- "S" in visual mode: add surround to visual select

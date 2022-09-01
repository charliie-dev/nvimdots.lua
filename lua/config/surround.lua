local status, surround = pcall(require, "nvim-surround")
if not status then
	return
end

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

surround.setup({
  move_cursor = false,  -- if true, the cursor moves to the beginning of the action.
})

return function()
	local gen_spec = require("mini.ai").gen_spec
	require("modules.utils").load_plugin("mini.ai", {
		-- Table with textobject id as fields, textobject specification as values.
		-- Also use this to disable builtin textobjects. See |MiniAi.config|.
		-- The af/if/ac/ic mappings (keymap/edit.lua) select Treesitter functions and classes. Typing
		-- `a`/`i` and the id slower than 'timeoutlen' lands here instead, so point f and c at the same
		-- nodes; mini.ai's function call moves to F.
		custom_textobjects = {
			f = gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
			c = gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
			F = gen_spec.function_call(),
		},

		-- Module mappings. Use `''` (empty string) to disable one.
		mappings = {
			-- Main textobject prefixes
			around = "a",
			inside = "i",

			-- Next/last textobjects
			around_next = "an",
			inside_next = "in",
			around_last = "al",
			inside_last = "il",

			-- Move cursor to corresponding edge of `a` textobject
			goto_left = "g[",
			goto_right = "g]",
		},

		-- Number of lines within which textobject is searched
		n_lines = 50,

		-- How to search for object (first inside current line, then inside
		-- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
		-- 'cover_or_nearest', 'next', 'prev', 'nearest'.
		search_method = "cover_or_next",

		-- Whether to disable showing non-error feedback
		silent = false,
	})
end

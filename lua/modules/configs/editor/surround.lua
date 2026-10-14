return function()
	require("modules.utils").load_plugin("mini.surround", {
		-- Flash jumps with `s` in Normal, Visual and Operator-pending mode. Surround's default `s`
		-- prefix made `s` wait 'timeoutlen' and run surround when a/d/r/f/F/h followed quickly, so
		-- surround lives under `gz` instead.
		mappings = {
			add = "gza",
			delete = "gzd",
			find = "gzf",
			find_left = "gzF",
			highlight = "gzh",
			replace = "gzr",
		},
	})
end

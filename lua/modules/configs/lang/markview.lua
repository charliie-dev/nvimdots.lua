return function()
	require("modules.utils").load_plugin("markview", {
		preview = {
			modes = { "n", "no", "c" },
			hybrid_modes = { "n" },
			callbacks = {
				on_enable = function(_, win)
					vim.wo[win].conceallevel = 2
					vim.wo[win].concealcursor = "c"
				end,
			},
		},
	})
end

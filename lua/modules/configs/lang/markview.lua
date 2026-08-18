return function()
	require("modules.utils").load_plugin("markview", {
		preview = {
			modes = { "n", "no", "c" },
			hybrid_modes = { "n" },
		},
	})
end

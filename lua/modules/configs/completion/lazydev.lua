return function()
	require("modules.utils").load_plugin("lazydev", {
		library = {
			"lazy.nvim",
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	})
end

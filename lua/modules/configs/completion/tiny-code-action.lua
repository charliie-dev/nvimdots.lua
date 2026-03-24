return function()
	require("modules.utils").load_plugin("tiny-code-action", {
		backend = "delta",
		backend_opts = {
			delta = {
				header_lines_to_remove = 4,
				args = { "--line-numbers" },
			},
		},
	})
end

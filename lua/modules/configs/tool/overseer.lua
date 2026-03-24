return function()
	require("modules.utils").load_plugin("overseer", {
		strategy = "terminal",
		templates = { "builtin" },
		task_list = {
			direction = "bottom",
			default_detail = 1,
		},
	})
end

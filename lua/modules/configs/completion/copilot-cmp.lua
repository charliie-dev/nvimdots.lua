return function()
	require("modules.utils").load_plugin("copilot_cmp", {
		method = "getCompletionsCycling",
		-- formatters = {
		-- 	label = require("copilot_cmp.format").format_label_text,
		-- 	insert_text = require("copilot_cmp.format").remove_existing,
		-- 	preview = require("copilot_cmp.format").deindent,
		-- },
	})
end

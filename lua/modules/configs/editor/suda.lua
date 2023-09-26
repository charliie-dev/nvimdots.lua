return function()
	vim.g["suda#prompt"] = "Enter admin password: "

	require("modules.utils").load_plugin("suda", nil, true)
end

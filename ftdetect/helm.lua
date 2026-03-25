vim.filetype.add({
	pattern = {
		["helmfile[^/]*%.ya?ml"] = "yaml.helm-values",
		["values[^/]*%.ya?ml"] = {
			function(path)
				if path:find("charts?[/\\]") or path:find("helm[/\\]") then
					return "yaml.helm-values"
				end
			end,
		},
	},
})

vim.filetype.add({
	pattern = {
		["docker%-compose[^/]*%.ya?ml"] = "yaml.docker-compose",
		["compose[^/]*%.ya?ml"] = "yaml.docker-compose",
	},
})

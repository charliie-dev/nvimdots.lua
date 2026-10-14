-- Neovim has no Helm detection: chart templates read as yaml (or smarty for *.tpl), so helm_ls and
-- the helm treesitter parser never attach, and yamlls reports Go template syntax as YAML errors.
-- Only files inside a chart (the nearest ancestor with Chart.yaml) are reclassified.

local function template(path)
	local root = vim.fs.root(path, "Chart.yaml")
	if root and vim.startswith(path, root .. "/templates/") then
		return "helm"
	end
end

local function values(path)
	local root = vim.fs.root(path, "Chart.yaml")
	if root and vim.fs.dirname(path) == root then
		return "yaml.helm-values"
	end
end

vim.filetype.add({
	pattern = {
		[".*/templates/.*%.ya?ml"] = template,
		[".*/templates/.*%.tpl"] = template,
		[".*/templates/NOTES%.txt"] = template,
		[".*/values%.ya?ml"] = values,
		[".*/values[-.].*%.ya?ml"] = values,
	},
})

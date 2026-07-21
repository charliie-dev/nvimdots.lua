-- GitHub Actions workflow files get the dotted filetype so their dedicated
-- tooling keys on it: nvim-lint's `yaml.github` linters (actionlint + shuck)
-- and the LSP filetype claims in servers/yamlls.lua / servers/gh_actions_ls.lua.
-- Deliberately unanchored, same shape as ftdetect/gitlab.lua: an explicit `$`
-- (any variant) empirically stops vim.filetype.match from ever matching the
-- pattern on this nvim, so suffixed copies (ci.yml.bak) re-type too — accepted
-- parity with the gitlab precedent.
vim.filetype.add({
	pattern = {
		[".*/%.github/workflows/.*%.ya?ml"] = "yaml.github",
	},
})

-- https://ewhauser.github.io/shuck/docs/lsp/
-- Installed via mise (`cargo:shuck-cli`), not Mason. This override adds ksh,
-- excludes zsh, and uses project-specific root markers.
--
-- Shuck's zsh dialect misparses some zsh-isms, so zsh files remain on `zsh -n`
-- (nvim-lint) until its zsh support improves.
return {
	cmd = { "shuck", "server" },
	filetypes = { "sh", "bash", "ksh" },
	root_markers = { ".shuck.toml", "shuck.toml", ".git" },
}

-- https://ewhauser.github.io/shuck/docs/lsp/
-- Installed via mise (`cargo:shuck-cli`), not Mason. This override excludes zsh
-- and uses project-specific root markers.
--
-- Shuck's zsh dialect misparses some zsh-isms, so zsh files remain on `zsh -n`
-- (nvim-lint) until its zsh support improves.
--
-- No `ksh` entry: Neovim's shell detection always resolves korn scripts to
-- filetype `sh` and only records the dialect in `b:is_kornshell`.
return {
	cmd = { "shuck", "server" },
	filetypes = { "sh", "bash" },
	root_markers = { ".shuck.toml", "shuck.toml", ".git" },
}

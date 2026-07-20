-- shuck: Rust shell linter/formatter/language server.
-- https://ewhauser.github.io/shuck/docs/lsp/
-- No Mason package — installed via mise (`cargo:shuck-cli`); the resolver
-- enables it from the `shuck` binary on $PATH (fix = `mise install`).
-- `zsh` is intentionally excluded: shuck's zsh dialect still misparses some
-- zsh-isms and emits false positives, so zsh stays on `zsh -n` (nvim-lint).
return {
	cmd = { "shuck", "server" },
	filetypes = { "sh", "bash", "ksh" },
	root_markers = { ".shuck.toml", "shuck.toml", ".git" },
}

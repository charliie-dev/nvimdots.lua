-- shuck: Rust shell linter/formatter/language server.
-- https://ewhauser.github.io/shuck/docs/lsp/
-- Installed via mise (`cargo:shuck-cli`) by choice — Mason ships a shuck
-- package now, but under discovery-first the $PATH copy wins, so the
-- resolver enables it from the `shuck` binary (fix = `mise install`).
-- `zsh` is intentionally excluded: shuck's zsh dialect (as of v0.0.4x,
-- 2026-07) still misparses some zsh-isms and emits false positives, so zsh
-- stays on `zsh -n` (nvim-lint).
return {
	cmd = { "shuck", "server" },
	filetypes = { "sh", "bash", "ksh" },
	root_markers = { ".shuck.toml", "shuck.toml", ".git" },
}

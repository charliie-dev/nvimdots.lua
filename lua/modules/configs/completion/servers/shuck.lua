-- shuck: Rust shell linter/formatter/language server.
-- https://ewhauser.github.io/shuck/docs/lsp/
--
-- Installed via mise (`cargo:shuck-cli`), not Mason. It has no Mason package, so
-- its `lsp_deps` entry is resolved discovery-first from $PATH. cmd/filetypes/
-- root_markers are declared here so it works regardless of nvim-lspconfig.
--
-- Provides live diagnostics, code actions (incl. `source.fixAll.shuck`),
-- suppression-code hover, and document/range formatting over LSP.
--
-- `zsh` is intentionally excluded: shuck's zsh dialect still misparses some
-- zsh-isms (e.g. path literals inside `[(I)...]` subscripts) and emits false
-- positives, so zsh files are left to `zsh -n` (nvim-lint). Re-add "zsh" here
-- once shuck's zsh support is solid.
return {
	cmd = { "shuck", "server" },
	filetypes = { "sh", "bash", "ksh" },
	root_markers = { ".shuck.toml", "shuck.toml", ".git" },
}

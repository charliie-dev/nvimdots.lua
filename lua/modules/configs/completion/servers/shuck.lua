-- shuck: Rust shell linter/formatter/language server.
-- https://ewhauser.github.io/shuck/docs/lsp/
--
-- Installed via mise (`cargo:shuck-cli`), not Mason, so it is wired through
-- `settings.external_lsp_deps` rather than `lsp_deps`. shuck is not shipped in
-- nvim-lspconfig either, so cmd/filetypes/root_markers must be declared here.
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

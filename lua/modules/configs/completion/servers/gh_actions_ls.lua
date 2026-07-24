-- gh-actions-language-server: workflow-only by design (upstream root_dir gates
-- attach to .github/.forgejo/.gitea workflow dirs). Core attaches by EXACT
-- filetype match, so the dotted filetype from ftdetect/github.lua must be
-- claimed explicitly; plain `yaml` stays so the forgejo/gitea workflow dirs —
-- which the ftdetect pattern does not re-type — keep attaching as upstream
-- intends.
return {
	filetypes = { "yaml", "yaml.github" },
}

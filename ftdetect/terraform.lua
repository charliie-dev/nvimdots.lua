-- Neovim picks `tf` (TinyFugue) for empty *.tf buffers and only switches to terraform once the
-- file has content; always treat *.tf as Terraform so new files get the LSP, snippets and formatter.
vim.filetype.add({
	extension = {
		tf = "terraform",
	},
})

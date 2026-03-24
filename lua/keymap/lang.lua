local set = vim.keymap.set

-- Plugin: markview.nvim
set(
	"n",
	"<F1>",
	"<Cmd>Markview toggle<CR>",
	{ silent = true, desc = "tool: toggle markdown preview within nvim" }
)

-- Plugin: MarkdownPreview
set("n", "<F12>", "<Cmd>MarkdownPreviewToggle<CR>", { silent = true, desc = "tool: Preview markdown" })

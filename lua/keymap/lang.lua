local set = vim.keymap.set

-- Plugin: render-markdown.nvim
set("n", "<F1>", "<Cmd>RenderMarkdown toggle<CR>", { silent = true, desc = "tool: toggle markdown preview within nvim" })

-- Plugin: MarkdownPreview
set("n", "<F12>", "<Cmd>MarkdownPreviewToggle<CR>", { silent = true, desc = "tool: Preview markdown" })

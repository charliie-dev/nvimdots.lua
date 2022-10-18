-- Disable header folding
vim.g.vim_markdown_folding_disabled = true

-- Enable markdown conceal
vim.opt_local.conceallevel = 2
vim.g.vim_markdown_conceal = true
vim.g.vim_markdown_conceal_code_blocks = false

-- Fenced languages syntax highlight
vim.g.vim_markdown_fenced_languages = {
	"c==cpp",
	"viml=vim",
	"bash=sh",
	"ini=dosini",
	"py=python",
}

-- Highlight YAML/TOML/JSON front matter.
vim.g.vim_markdown_frontmatter = true
vim.g.vim_markdown_toml_frontmatter = true
vim.g.vim_markdown_json_frontmatter = true

-- Strikethrough uses two tildes.
vim.g.vim_markdown_strikethrough = true

-- Autosave before using `ge`.
vim.g.vim_markdown_autowrite = true

-- Let the TOC window autofit so that it doesn't take too much space
vim.g.vim_markdown_toc_autofit = true

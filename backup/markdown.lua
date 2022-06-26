-- disable header folding
vim.g.vim_markdown_folding_disabled = 0

-- do not use conceal feature, the implementation is not so good
vim.g.vim_markdown_conceal = 1

-- document title is expanded
vim.g.vim_markdown_folding_level = 1

-- allow for the toc window to auto-fit when it's possible for it to shrink.
vim.g.vim_markdown_toc_autofit = 0

-- to enable conceal use vim's standard conceal configuration.
vim.cmd([[let conceallevel=1]])

-- disable math tex conceal feature
vim.g.tex_conceal = "abdmg"
-- Used as $x^2$, $$x^2$$, escapable as \$x\$ and \$\$x\$\$
vim.g.vim_markdown_math = 1

-- use different name from filetype in code block
vim.g.vim_markdown_fenced_languages = {
	"c++=cpp",
	"viml=vim",
	"bash=sh",
	"ini=dosini",
	"py=python",
}

-- Highlight YAML front matter as used by Jekyll or Hugo.
vim.g.vim_markdown_frontmatter = 1

-- TOML syntax highlight requires vim-toml.
vim.g.vim_markdown_toml_frontmatter = 1

-- JSON syntax highlight requires vim-json.
vim.g.vim_markdown_json_frontmatter = 1

-- Strikethrough uses two tildes.
vim.g.vim_markdown_strikethrough = 1

-- Autosave before using `ge`.
vim.g.vim_markdown_autowrite = 1

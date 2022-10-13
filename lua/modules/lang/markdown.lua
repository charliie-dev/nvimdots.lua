vim.api.nvim_command([[
" disable header folding
let g:vim_markdown_folding_disabled = 1

" do not use conceal feature, the implementation is not so good
let g:vim_markdown_conceal = 1
let g:vim_markdown_conceal_code_blocks = 0

" document title is expanded
let g:vim_markdown_folding_level = 2

" To enable conceal use Vim's standard conceal configuration, if vim_markdown_conceal is not set
" setlocal conceallevel=2

" Disable math tex conceal and syntax highlight
let g:tex_conceal = ""
let g:vim_markdown_math = 0

" use different name from filetype in code block
let g:vim_markdown_fenced_languages = [
      \ 'c++=cpp', 'viml=vim', 'bash=sh', 'ini=dosini', 'py=python'
  \ ]

" Highlight YAML front matter as used by Jekyll or Hugo.
let g:vim_markdown_frontmatter = 1

" TOML syntax highlight.
let g:vim_markdown_toml_frontmatter = 1

" JSON syntax highlight.
let g:vim_markdown_json_frontmatter = 1

" Strikethrough uses two tildes.
let g:vim_markdown_strikethrough = 1

" Autosave before using `ge`.
let g:vim_markdown_autowrite = 1

" Let the TOC window autofit so that it doesn't take too much space
let g:vim_markdown_toc_autofit = 1
]])

" disable header folding
let g:vim_markdown_folding_disabled = 0

" do not use conceal feature, the implementation is not so good
let g:vim_markdown_conceal = 1
let g:vim_markdown_conceal_code_blocks = 1

" document title is expanded
let g:vim_markdown_folding_level = 1

" Allow for the TOC window to auto-fit when it's possible for it to shrink.
let g:vim_markdown_toc_autofit = 0

" To enable conceal use Vim's standard conceal configuration.
set conceallevel=1

" disable math tex conceal feature
let g:tex_conceal = "abdmg"
" Used as $x^2$, $$x^2$$, escapable as \$x\$ and \$\$x\$\$
let g:vim_markdown_math = 1

" use different name from filetype in code block
let g:vim_markdown_fenced_languages = [
      \ 'c++=cpp', 'viml=vim', 'bash=sh', 'ini=dosini', 'py=python'
  \ ]

" Highlight YAML front matter as used by Jekyll or Hugo.
let g:vim_markdown_frontmatter = 1

" TOML syntax highlight requires vim-toml.
let g:vim_markdown_toml_frontmatter = 1

" JSON syntax highlight requires vim-json.
let g:vim_markdown_json_frontmatter = 1

" Strikethrough uses two tildes.
let g:vim_markdown_strikethrough = 1

" Autosave before using `ge`.
let g:vim_markdown_autowrite = 1

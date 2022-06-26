if !exists('g:loaded_vimtex') | finish | endif

let g:tex_flavor='xelatex --shell-escape'
let g:vimtex_view_general_viewer='xdg-open'
let g:vimtex_view_method = 'xdg-open'
let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
let g:vimtex_view_general_options_latexmk = '--unique'
let g:vimtex_quickfix_mode=0
let g:vimtex_quickfix_autoclose_after_keystrokes=3
let g:vimtex_complete_enabled=1
let g:vimtex_compiler_progname = 'nvr'
let g:vimtex_compiler_engine = 'latexmk'
let g:vimtex_view_general_automatic=0

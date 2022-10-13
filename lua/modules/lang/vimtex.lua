vim.api.nvim_command([[
if !exists('g:loaded_vimtex') | finish | endif

let g:vimtex_enabled=1
let g:tex_flavor='xelatex --shell-escape'
let g:vimtex_view_general_options='--unique file:@pdf\#src:@line@tex'
let g:vimtex_quickfix_mode=0
let g:vimtex_quickfix_autoclose_after_keystrokes=3
let g:vimtex_complete_enabled=1
let g:vimtex_compiler_progname='nvr'
let g:vimtex_compiler_method='latexmk'
let g:vimtex_view_general_automatic=0

if has('win32') || (has('unix') && exists('$WSLENV'))
    let g:vimtex_view_method = 'sioyek'
    " NOTE: Remember to `ln -s /path/in/windows/sioyek.exe /usr/local/bin/sioyek.exe`
    let g:vimtex_view_sioyek_exe = 'sioyek.exe'
    let g:vimtex_callback_progpath = 'wsl nvim'
endif
]])

" File types "{{{
" ---------------------------------------------------------------------
" JavaScript
au BufNewFile,BufRead *.es6 setf javascript
" TypeScript
au BufNewFile,BufRead *.tsx setf typescriptreact
" Markdown
au BufNewFile,BufRead *.md set filetype=markdown
au BufNewFile,BufRead *.mdx set filetype=markdown
" Bash
au BufNewFile,BufRead *.sh set filetype=bash
" Python IPython
au BufNewFile,BufRead *.py set filetype=python
au BufNewFile,BufRead *ipynb set filetype=python


" " python
" " vim-python
" augroup vimrc-python
"   autocmd!
"   autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=8 colorcolumn=79
"       \ formatoptions+=croq softtabstop=4
"       \ cinwords=if,elif,else,for,while,try,except,finally,def,class,with
" augroup END
"
" " Syntax highlight
" let python_highlight_all = 1

"}}}

" Extras "{{{
" ---------------------------------------------------------------------
" Remove trailing whitespace when save
au BufWritePre * :%s/\s\+$//e

" How to copy to clipboard in vim of Bash on Windows?
autocmd TextYankPost * if v:event.operator ==# 'y' | call system('/mnt/c/Windows/System32/clip.exe', @0) | endif

" focus on directory of current buffer
autocmd BufEnter * silent! lcd %:p:h

" File <F5> execute
" Python
if executable('python3')
  au BufRead,BufNewFile *.py noremap <F5> :% w !python<CR>
else
  echo "No python3 found"
endif

" JavaScript
if executable('node')
  au BufRead,BufNewFile *.js noremap <F5> :% w !node<CR>
else
  echo "No node found"
endif

" Open md files with toc if there's one.
au BufRead *.md :call OpenMd()

function! OpenMd()
    setlocal foldlevel=1
    SymbolsOutline
endfunction

" set exrc " sudoer privileges to open/execute files you don't have ownership of

" " Faster startup time for wilder
" " ++once supported in Nvim 0.4+ and Vim 8.1+
" autocmd CmdlineEnter * ++once call s:wilder_init() | call s:wilder#main#start()
"
" function! s:wilder_init() abort
"   call wilder#setup(...)
"
"   call wilder#set_option('pipeline', ...)
"   call wilder#set_option('renderer', ...)
" endfunction

"}}}

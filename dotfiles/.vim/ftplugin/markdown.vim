
" Markdown needs spaces, not tabs
setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4

setlocal formatoptions+=tp1nw formatoptions-=]a

setlocal wrap
setlocal joinspaces
setlocal colorcolumn=80,120

"augroup myformatting
"    autocmd!
"    autocmd InsertLeave * normal gwap<CR>
"augroup END


" Header lines are followed by two breaks.
" Paragraphs are wrapped at the end of sentences.
" Sentenced which wrapped line are merged onto the same line.
" Sentence terminations must not be followed by whitespace.
nnoremap <Leader>wr :silent! %s/^#\s\+\([^\n]\+\)\n\+\(\w\+\)/# \1\r\r\2/g<CR>
            \:silent! %s/\(\w\+[.?!]\)\s\+\(\w\+\)/\1\r\2/g<CR>
            \:silent! %s/^([^#].*)\(\w\+\)\n\+\(\w\+\)/\1\2 \3/g<CR>
            \:silent! %s/\(\w\+[.?!]\)\s*\(\n\+\)/\1\2/g<CR>
            \:silent! let @/=''<CR>

" Activate dictionary completion for text files
if has('spell')
    setlocal complete+=k spell
endif

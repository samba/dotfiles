" Highlight: Cursor Line and Column {{{
" Cursor Line highlight
set cursorline                  "cul:   highlights the current line
set cursorcolumn                "cuc:   highlights the current column

" I love the new CursorLine, but terminal underlining kicks legibility in the nuts.
" So what to do? Bold is (extremely) subtle, but it's better than nothing.
hi CursorLine   cterm=bold      ctermbg=none
hi CursorColumn cterm=bold      ctermbg=none


"}}}


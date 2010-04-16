
" Navigation: Windows {{{
set splitright                  "spr:   puts new vsplit windows to the right of the current
set splitbelow                  "sb:    puts new split windows to the bottom of the current

set winminheight=0              "wmh:   the minimal line height of any non-current window
set winminwidth=0               "wmw:   the minimal column width of any non-current window
" Window visuals {{{


"}}}


" WINDOW NAVIGATION  SHORTCUTS {{{
" Shortcut for Window controls: Control-W
" use <F2> to cycle through split windows (and <Shift>+<F2> to cycle backwards,
" where possible):
noremap <silent> <F2> <C-W>w
noremap <silent> <S-F2> <C-W>W


" Map C-W for easy switching (even in insert mode)
inoremap <C-w> <C-o><C-w>



"}}}
"}}}


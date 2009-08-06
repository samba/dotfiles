
" Navigation: Windows {{{
set splitright                  "spr:   puts new vsplit windows to the right of the current
set splitbelow                  "sb:    puts new split windows to the bottom of the current

set winminheight=0              "wmh:   the minimal line height of any non-current window
set winminwidth=0               "wmw:   the minimal column width of any non-current window
" Window visuals {{{
hi VertSplit cterm=bold ctermfg=Grey ctermbg=none
hi HorizSplit cterm=bold ctermfg=Grey ctermbg=none

" I like this better than all the reverse video of the default statusline.
hi StatusLine cterm=bold,underline ctermfg=White ctermbg=none
hi StatusLineNC cterm=underline ctermfg=DarkBlue ctermbg=none
hi User1 ctermfg=DarkRed
hi User2 ctermfg=DarkBlue
hi User3 ctermfg=DarkMagenta
hi User4 cterm=bold ctermfg=DarkGrey
hi User5 ctermfg=Brown
hi User6 ctermfg=DarkGreen
hi User7 ctermfg=DarkGreen
hi User8 cterm=bold ctermfg=DarkCyan
hi User9 cterm=bold ctermfg=DarkGrey ctermbg=none


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


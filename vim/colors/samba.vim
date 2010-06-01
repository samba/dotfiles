hi clear

if exists("syntax_on")
  syntax reset
endif


hi LineNr cterm=none ctermfg=DarkGreen ctermbg=none
" rndstr: hi LineNr cterm=none ctermfg=Black ctermbg=DarkBlue

" show - and = to indicate current window
" set fillchars+=stl:=,stlnc:_


" Omnifunc and other menus: {{{
hi Pmenu cterm=none ctermfg=none ctermbg=DarkGreen
hi PmenuSel cterm=none ctermfg=Green ctermbg=none
hi PmenuSbar cterm=bold ctermfg=none ctermbg=Green
hi PmenuThumb cterm=bold ctermfg=Blue ctermbg=black
" }}}


" I love the new CursorLine, but terminal underlining ruins legibility.
" So what to do? Bold is (extremely) subtle, but it's better than nothing.
hi CursorLine   cterm=bold ctermbg=none
hi CursorColumn cterm=bold ctermbg=none



" FOLDING
" The default fold color is too bright and looks too much like the statusline
hi Folded ctermfg=LightRed ctermbg=NONE cterm=NONE
hi FoldColumn ctermfg=LightRed ctermbg=NONE cterm=NONE
set fillchars+=fold:¬


" TABS - i keep it consistent with my window and status colors
hi TabLine cterm=underline ctermfg=LightBlue ctermbg=none
hi TabLineSel cterm=bold,underline ctermfg=White ctermbg=none
hi TabLineFill cterm=underline ctermfg=LightBlue ctermbg=none

" rndstr: 
" hi TabLine cterm=none ctermfg=Black ctermbg=Gray
" hi TabLineSel cterm=bold,underline ctermfg=Gray ctermbg=DarkRed
" hi TabLineFill cterm=none ctermfg=DarkRed ctermbg=Gray




" SPLIT WINDOWS
hi VertSplit cterm=bold ctermfg=Grey ctermbg=none
hi HorizSplit cterm=bold ctermfg=Grey ctermbg=none

" STATUS LINE
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




" Extra Whitespace and the like
" Composed of various sources:
"   http://github.com/rndstr/dotfiles/tree/master/vim/ 
"   http://blog.kamil.dworakowski.name/2009/09/unobtrusive-highlighting-of-trailing.html
"   http://vim.wikia.com/wiki/Highlight_unwanted_spaces
" see also: http://vimregex.com/#pattern

highlight ExtraWhitespace ctermbg=DarkGreen guibg=DarkGreen
au ColorScheme * highlight ExtraWhitespace ctermbg=DarkGreen

" Show leading whitespace that includes spaces, and trailing whitespace.
au BufWinEnter,BufEnter * match ExtraWhitespace /\s\+$/
au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
au InsertLeave * match ExtraWhiteSpace /\s\+$/


" hi Comment cterm=none ctermfg=6
" hi PreProc cterm=bold ctermfg=4
" hi Special cterm=bold ctermfg=1
" hi Identifier cterm=none ctermfg=6



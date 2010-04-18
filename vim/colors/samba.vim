hi clear

if exists("syntax_on")
  syntax reset
endif


hi LineNr term=italic cterm=NONE ctermfg=DarkGreen ctermbg=none 
" rndstr: hi LineNr cterm=none ctermfg=0 ctermbg=4

" show - and = to indicate current window
" set fillchars+=stl:=,stlnc:_


" Omnifunc and other menus: {{{
hi Pmenu cterm=none ctermfg=Green ctermbg=none
hi PmenuSel cterm=underline ctermfg=White ctermbg=none
hi PmenuSbar cterm=bold ctermfg=none ctermbg=DarkBlue
hi PmenuThumb cterm=bold ctermfg=none ctermbg=White

" }}}


" I love the new CursorLine, but terminal underlining ruins legibility.
" So what to do? Bold is (extremely) subtle, but it's better than nothing.
hi CursorLine   cterm=bold      ctermbg=none
hi CursorColumn cterm=bold      ctermbg=none



" FOLDING
" The default fold color is too bright and looks too much like the statusline
hi Folded cterm=bold ctermfg=DarkBlue ctermbg=none
hi FoldColumn cterm=bold ctermfg=DarkBlue ctermbg=none
set fillchars+=fold:_


" TABS
hi TabLine cterm=underline ctermfg=LightBlue ctermbg=none
hi TabLineSel cterm=bold,underline ctermfg=White ctermbg=none
hi TabLineFill cterm=underline ctermfg=LightBlue ctermbg=none
" rndstr: hi TabLine cterm=none ctermfg=0 ctermbg=7
" rndstr: hi TabLineSel cterm=bold,underline ctermfg=7 ctermbg=4
" rndstr: hi TabLineFill cterm=none ctermfg=4 ctermbg=7




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





"" These taken from rndstr's scheme
highlight ExtraWhitespace ctermbg=5 guibg=darkgreen
match ExtraWhitespace /\t/

" hi Comment cterm=none ctermfg=6
" hi PreProc cterm=bold ctermfg=4
" hi Special cterm=bold ctermfg=1
" hi Identifier cterm=none ctermfg=6



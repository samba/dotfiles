" Vim color file
" Maintainer: Roland Schilter
" Last Change: 2010 Feb 17
"
" :colorscheme rndstr
" :he cterm-colors
" :so $VIMRUNTIME/syntax/hitest.vim

hi clear Normal
set bg& 

" Remove all existing highlighting and set the defaults.
hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
  syntax reset
endif

let colors_name = "rndstr"


highlight ExtraWhitespace ctermbg=5 guibg=darkgreen
match ExtraWhitespace /\t/

hi Comment cterm=none ctermfg=6
hi PreProc cterm=bold ctermfg=4
hi LineNr cterm=none ctermfg=0 ctermbg=4
hi Special cterm=bold ctermfg=1
hi Identifier cterm=none ctermfg=6

hi TabLine cterm=none ctermfg=0 ctermbg=7
hi TabLineSel cterm=bold,underline ctermfg=7 ctermbg=4
hi TabLineFill cterm=none ctermfg=4 ctermbg=7



" vim: sw=2 

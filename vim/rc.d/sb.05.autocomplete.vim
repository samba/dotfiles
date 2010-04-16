" Code Completion {{{
" CODE COMPLETION SHORTCUTS {{{
" User-dictionary completion (usually syntax completion)
"imap <C-U>c <C-X><C-U>
" Omnifunc completion (uses supplied omnifunc if available.)
"imap <C-O>c <C-X><C-O>

" Default completion shortcuts...
" References:
"   http://www.thegeekstuff.com/2008/12/vi-and-vim-editor-3-steps-to-enable-thesaurus-option/
"   http://www.thegeekstuff.com/2009/01/vi-and-vim-editor-5-awesome-examples-for-automatic-word-completion-using-ctrl-x-magic/
" Word/Pattern complete (instances from same file)
" C-x C-p   search previous
" C-x C-n   search next/forward
" Line completion
" C-x C-l   lists similar lines
" Filename completion
" C-x C-f   lists similar file names
" Dictionary
" C-x C-k
" Thesaurus
" C-x C-t
" Code completion
" C-x C-u   from syntax file
" C-x C-o   from API reference




" inoremap <expr> . MayComplete()
" func MayComplete()
"     if ()
"         return".\<C-X>\<C-O>"
"     endif
"     return '.'
" endfunc
"}}}


" Use cool tab-completion menu
set wildmenu
set wildignore+=*.o,*.obj,*~,.lo,.so
set suffixes+=.in,.a

set pumheight=12
"}}}


" Use cool tab-completion menu
set wildmenu
set wildignore+=*.o,*.obj,*~,.lo,.so
set suffixes+=.in,.a

" Maximum menu height
set pumheight=12


" A dictionary for autocomplete
set dictionary+=/usr/share/dict/words

" via http://vim.wikia.com/wiki/VimTip1386
set completeopt=longest,menuone,preview
noremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" and this lets me refine results by continuing to type
inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
inoremap <expr> <M-,> pumvisible() ? '<C-n>' :
  \ '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>


inoremap <Nul> <C-x><C-o>





" Default completion shortcuts...
" References:
"   http://www.thegeekstuff.com/2008/12/vi-and-vim-editor-3-steps-to-enable-thesaurus-option/
"   http://www.thegeekstuff.com/2009/01/vi-and-vim-editor-5-awesome-examples-for-automatic-word-completion-using-ctrl-x-magic/

" Word/Pattern complete (instances from same file)
" C-x C-p   search previous
" C-x C-n   search next/forward

" Line completion: C-x C-l   lists similar lines
" Filename completion: C-x C-f   lists similar file names
" Dictionary: C-x C-k
" Thesaurus: C-x C-t

" Code completion
" C-x C-u   from syntax file
" C-x C-o   from API reference

" User-dictionary completion (usually syntax completion)
"imap <C-U>c <C-X><C-U>
" Omnifunc completion (uses supplied omnifunc if available.)
"imap <C-O>c <C-X><C-O>





" Load syntax-completion by default
set omnifunc=syntaxcomplete#Complete
" Per-file omnifunc settings are in filetypes.vim



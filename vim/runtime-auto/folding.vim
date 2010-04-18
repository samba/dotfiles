" reference: http://varnit.wordpress.com/2007/10/23/vim-code-folding/
set foldenable


" method=syntax isn't entirely reliable, as some syntax files don't include folding
set foldmethod=indent	 " useful options: indent, marker, syntax, expr (determined by 'foldexpr')
set foldcolumn=2                "fdc:   creates a small left-hand gutter for displaying fold info



" Spacebar toggles a fold, zi toggles all folding, zM closes all folds
nnoremap  <silent>  <space> :exe 'silent! normal! za'.(foldlevel('.')?'':'l')<cr>

" Automatic save of folds, so that you dont have to type everytime 
" :mkview to save and :loadview to restore folds
au BufWinLeave * silent! mkview
au BufWinEnter * silent! loadview


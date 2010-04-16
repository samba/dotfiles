" Code Folding {{{
" reference: http://varnit.wordpress.com/2007/10/23/vim-code-folding/

" syntax isn't entirely reliable, as some syntax files don't include folding
"set foldmethod=syntax
set foldmethod=indent		" useful options: indent, marker, syntax, expr (determined by 'foldexpr')
set foldcolumn=4                "fdc:   creates a small left-hand gutter for displaying fold info

" For BASH and similar shell languages:
" :help bash
" let g:is_sh = 1
" let g:is_bash = 1
" let g:is_posix = 1
" let g:is_kornshell = 1
" let g:sh_fold_enabled = {0:none,1:function,2:heredoc,4:if/do/for} (or a sum of them)
let g:sh_fold_enabled=8
let sh_minlines=500
let sh_maxlines=1000

" {{{ Automatic save of folds, 
" so that you dont have to type everytime :mkview to
" save and :loadview to restore folds
au BufWinLeave * silent! mkview
au BufWinEnter * silent! loadview
" }}}
" SHORTCUTS {{{

" Spacebar toggles a fold, zi toggles all folding, zM closes all folds
nnoremap  <silent>  <space> :exe 'silent! normal! za'.(foldlevel('.')?'':'l')<cr>
"}}}



"}}}



" Easy tab completion
" via https://github.com/garybernhardt/dotfiles/blob/main/.vimrc
function! InsertTabWrapper(key)
    let col = col('.') - 1
    if !col
        return "\<tab>"
    endif

    let char = getline('.')[col - 1]
    if char =~ '\k'
        " There's an identifier before the cursor, so complete the identifier.
        return a:key
    else
        return "\<tab>"
    endif
endfunction


function! tabcomplete#bind()

    " Use default context complete
    let b:TabCompletionMode="\<c-p>"

    " Use omnicomplete for sensible languages
    autocmd FileType go,python,javascript,rust let b:TabCompletionMode="\<c-x>\<c-o>"

    " Regular tab-completion tries exisitng words in the codebase
    autocmd BufReadPost * :imap <expr> <tab> InsertTabWrapper(b:TabCompletionMode)

    " Shift-Tab completion picks the nearest matching string
    imap <expr> <s-tab> InsertTabWrapper("\<c-n>")


endfunction


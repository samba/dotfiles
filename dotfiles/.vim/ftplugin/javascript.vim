
" Javascript {{{
set omnifunc=javascriptcomplete#CompleteJS

if executable('closure')
    setlocal makeprg=closure\ --test\ -p\ '%'
endif


if has('folding')
    setlocal foldenable foldmethod=indent
endif



" }}} end Javascript


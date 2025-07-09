
" Let the enter key take me to navigate help files
nmap <buffer> <CR> <C-]>

if has('folding')
    setlocal foldcolumn=0 nonumber foldenable foldmethod=marker "no foldcolumn for help files
endif


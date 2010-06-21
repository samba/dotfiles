" Additional customizations (e.g. keybindings) for certain file types


autocmd FileType sql set omnifunc=sqlcomplete#Complete
autocmd FileType ruby set omnifunc=rubycomplete#Complete
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete





" let the enter key take me to navigate help files
au FileType help nmap <buffer> <CR> <C-]>
au FileType help set foldcolumn=0 nonumber "no foldcolumn for help files

" Makefiles should permit tabs.
au FileType make setlocal noexpandtab

" Configuration files should permit hex colors
au FileType conf
    \  syn match confColor  "#\x\{2,6}" transparent |
    \  hi def link confColor  String


" We want consistent spacing in Python, and not tabs.
au FileType python setlocal ai sw=4 ts=4 sta et

" And an easy way to check syntax...
au FileType python set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\" 
au FileType python set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m 

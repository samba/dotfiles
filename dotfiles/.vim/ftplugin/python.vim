
" Python {{{
" We want consistent spacing in Python, and not tabs.
setlocal ai tabstop=4 softtabstop=4 shiftwidth=4 textwidth=80 smarttab expandtab

" And an easy way to check syntax...
setlocal makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
setlocal efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m

setlocal omnifunc=pythoncomplete#Complete

if has('folding')
    setlocal noet foldenable foldmethod=indent
endif


" }}} end Python


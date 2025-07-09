" Shortcuts and configuration for Go code files (golang)
setlocal tabstop=4 shiftwidth=4 softtabstop=4
setlocal noet


setlocal omnifunc=go#complete#Complete


" Coverage {{{
nnoremap <buffer> <Leader>co <Plug>(go-coverage-toggle)
nnoremap <buffer> <Leader>cob <Plug>(go-coverage-browser)
nnoremap <buffer> <Leader>cov <Plug>(go-coverage)
" }}}



" Testing {{{
nnoremap <buffer> <leader>t <Plug>(go-test)

" Compiles but does not test!
nnoremap <buffer> <leader>tc <Plug>(go-test-compile)

" Only test the function under the cursor.
nnoremap <buffer> <leader>tf <Plug>(go-test-func)

" Opens test & implementation side-by-side (or below)
nnoremap <buffer> <Leader>as <Plug>(go-alternate-split)
nnoremap <buffer> <Leader>av <Plug>(go-alternate-vertical)



" }}}


" Symbol discovery, navigation, docs, etc {{{
nnoremap <buffer> <Leader>i <Plug>(go-info)
nnoremap <buffer> <Leader>do <Plug>(go-doc)
nnoremap <buffer> <Leader>ds <Plug>(go-doc-split)
nnoremap <buffer> <Leader>dv <Plug>(go-doc-vertical)
nnoremap <buffer> <Leader>dt <Plug>(go-doc-tab)

" Show dependencies of current package
nnoremap <buffer> <Leader>dp <Plug>(go-deps)

" Go symbol navigation
nnoremap <buffer> <Leader>f <Plug>(go-def)
nnoremap <buffer> <Leader>fy <Plug>(go-def-type-split)
nnoremap <buffer> <Leader>fs <Plug>(go-def-split)
nnoremap <buffer> <Leader>fk <Plug>(go-def-stack)
nnoremap <buffer> <Leader>fc <Plug>(go-def-stack-clear)
nnoremap <buffer> <Leader>fp <Plug>(go-def-pop)


nnoremap <buffer> <Leader>im <Plug>(go-implements)
nnoremap <buffer> <Leader>cl <Plug>(go-callees)
nnoremap <buffer> <Leader>cr <Plug>(go-callers)

" nnoremap <buffer> <leader>gin <Plug>(go-info)
nnoremap <buffer> <Leader>dc <Plug>(go-describe)
nnoremap <buffer> <Leader>cs <Plug>(go-callstack)
nnoremap <buffer> <Leader>fv <Plug>(go-freevars)
nnoremap <buffer> <Leader>cp <Plug>(go-channelpeers)
nnoremap <buffer> <Leader>rf <Plug>(go-referrers)
nnoremap <buffer> <Leader>pt <Plug>(go-pointsto)



" }}}


" nnoremap <buffer> <Leader>gr <Plug>(go-run)
nnoremap <buffer> <leader>r :!clear<cr><Plug>(go-run)
nnoremap <buffer> <Leader>gb <Plug>(go-build)

" Hygiene {{{
nnoremap <buffer> <Leader>gv <Plug>(go-vet)
nnoremap <buffer> <Leader>gl <Plug>(go-lint)
nnoremap <buffer> <Leader>gml <Plug>(go-metalinter)

" Calls :GoImport for the current package
nnoremap <buffer> <Leader>gi <Plug>(go-import)
" Calls goimports (CLI) for the current package
nnoremap <buffer> <Leader>gim <Plug>(go-imports)


" }}}

" Refactoring {{{
nnoremap <buffer> <Leader>rn <Plug>(go-rename)
" }}}

" Generates an `if err != nil` clause
nnoremap <buffer> <Leader>ie <Plug>(go-if-err)




" vim: set foldmethod=marker

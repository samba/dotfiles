" Shortcuts and configuration for Go code files (golang)
setlocal tabstop=4 shiftwidth=4 softtabstop=4



nnoremap <leader>b :<C-u>call Build_go_files()<cr>
nnoremap <Leader>co <Plug>(go-coverage-toggle)
nnoremap <Leader>cob <Plug>(go-coverage-browser)
nnoremap <Leader>i <Plug>(go-info)
nnoremap <leader>r :!clear<cr><Plug>(go-run)
nnoremap <leader>t <Plug>(go-test)

" Compiles but does not test!
nnoremap <leader>tc <Plug>(go-test-compile)

" Only test the function under the cursor.
nnoremap <leader>tf <Plug>(go-test-func)


" nmap <buffer> <Leader>gr <Plug>(go-run)
nmap <buffer> <Leader>gb <Plug>(go-build)
" nmap <buffer> <Leader>gta <Plug>(go-test)
" nmap <buffer> <Leader>gtf <Plug>(go-test-func)
" nmap <buffer> <Leader>gtc <Plug>(go-test-compile)
nmap <buffer> <Leader>gcv <Plug>(go-coverage)
" nmap <buffer> <Leader>gcc <Plug>(go-cloverage-toggle)
nmap <buffer> <Leader>gl <Plug>(go-lint)
nmap <buffer> <Leader>gv <Plug>(go-vet)
nmap <buffer> <Leader>gdp <Plug>(go-deps)
nmap <buffer> <Leader>gdo <Plug>(go-doc)
nmap <buffer> <Leader>gds <Plug>(go-doc-split)

" Go symbol navigation
nmap <buffer> <Leader>gs <Plug>(go-def)
nmap <buffer> <Leader>gds <Plug>(go-def-split)
nmap <buffer> <Leader>gdt <Plug>(go-def-tab)
nmap <buffer> <Leader>gdk <Plug>(go-def-stack)
nmap <buffer> <Leader>gtx <Plug>(go-def-stack-clear)


nmap <buffer> <Leader>gti <Plug>(go-implements)
nmap <buffer> <Leader>grn <Plug>(go-rename)
nmap <buffer> <Leader>gca <Plug>(go-callees)
nmap <buffer> <Leader>gcr <Plug>(go-callers)

" nmap <buffer> <leader>gin <Plug>(go-info)
nmap <buffer> <Leader>gdc <Plug>(go-describe)
nmap <buffer> <Leader>gcs <Plug>(go-callstack)
nmap <buffer> <Leader>gfv <Plug>(go-freevars)
nmap <buffer> <Leader>gcp <Plug>(go-channelpeers)
nmap <buffer> <Leader>grf <Plug>(go-referrers)
nmap <buffer> <Leader>gpt <Plug>(go-pointsto)
nmap <buffer> <Leader>gml <Plug>(go-metalinter)
nmap <buffer> <Leader>gas <Plug>(go-alternate-split)
nmap <buffer> <Leader>gav <Plug>(go-alternate-vertical)

" Calls :GoImport for the current package
nmap <buffer> <Leader>gi <Plug>(go-import)
" Calls goimports (CLI) for the current package
nmap <buffer> <Leader>gim <Plug>(go-imports)

" Generates an `if err != nil` clause
nmap <buffer> <Leader>gie <Plug>(go-if-err)






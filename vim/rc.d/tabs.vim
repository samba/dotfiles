" :T = :tabedit
command! -nargs=* -complete=file T tabedit <args>
"nnoremap :e :tabedit
nnoremap <silent> = :tabnext<CR>
nnoremap <silent> + :tabprev<CR>
nnoremap <silent> <C-tab> :tabs<CR>
" go to file
nnoremap gf <C-W>gf


" always show the tabline
set showtabline=2
set tabpagemax=20


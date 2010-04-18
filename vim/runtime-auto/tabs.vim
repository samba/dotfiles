
" This lets me toggle between tabs
let g:lasttab = 1   " default to the first tab, so it won't complain when there's only one.
autocmd TabLeave * let g:lasttab = tabpagenr()

function TabNext (i)
  exe 'tabnext ' . (a:i)
endfunc


" Tab navigation shortcuts (for normal-mode)
map t :tabs<CR>
map t<Left> :tabprev<CR>
map t<Right> :tabnext<CR>
map tn :tabnew<CR>
map tE :Texplore<CR>
map tX :tabclose<CR>
map tO :tabonly<CR>
map tm :tabs<CR>:tabmove<Space>
map tt :call TabNext(g:lasttab)<CR>
map tF :tabfind<Space>


" Insert-mode shortcut to prototype those above
imap <C-t> <Esc>t

" Firefox-style tab control:
" http://genotrance.wordpress.com/2008/02/04/my-vim-customization/

" A quick shortcut for opening files by cursor position
nnoremap gf <C-W>gf



set showtabline=1               "stal:  Display the tabbar if there are multiple tabs. Use :tab ball or invoke Vim with -p
set tabpagemax=6


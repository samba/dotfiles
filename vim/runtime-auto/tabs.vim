
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
map tg :tabnext<space>


" Insert-mode shortcut to prototype those above
imap <C-t> <Esc>t

" Firefox-style tab control:
" http://genotrance.wordpress.com/2008/02/04/my-vim-customization/

" A quick shortcut for opening files by cursor position - in a new tab
nnoremap gf <C-W>gf



" Use :tab ball or invoke Vim with -p ... to open all buffers in new tabs
set showtabline=1               "stal:  Display the tabbar if there are multiple tabs. 
set tabpagemax=6


" set tabline=%!MyTabLine()

" set guitablabel=%{GuiTabLabel()}


" set up tab labels with tab number, buffer name, number of windows
function! GuiTabLabel()
  let label = ''
  let bufnrlist = tabpagebuflist(v:lnum)

  " Add '+' if one of the buffers in the tab page is modified
  for bufnr in bufnrlist
    if getbufvar(bufnr, "&modified")
      let label = '+'
      break
    endif
  endfor

  " Append the tab number
  let label .= v:lnum.': '

  " Append the buffer name
  let name = bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])
  if name == ''
    " give a name to no-name documents
    if &buftype=='quickfix'
      let name = '[Quickfix List]'
    else
      let name = '[No Name]'
    endif
  else
    " get only the file name
    let name = fnamemodify(name,":t")
  endif
  let label .= name

  " Append the number of windows in the tab page
  let wincount = tabpagewinnr(v:lnum, '$')
  return label . '  [' . wincount . ']'
endfunction

function! MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let s .= '%' . (i + 1) . 'T'

    " the label is made by MyTabLabel()
    let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'

  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let s .= '%=%#TabLine#%999X X'
  endif

  "echomsg 's:' . s
  return s
endfunction

function! MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let numtabs = tabpagenr('$')
  " account for space padding between tabs, and the "close" button
  let maxlen = ( &columns - ( numtabs * 2 ) - 4 ) / numtabs
  let tablabel = bufname(buflist[winnr - 1])
  while strlen( tablabel ) < 4
    let tablabel = tablabel . " "
  endwhile
  let tablabel = fnamemodify( tablabel, ':t' )
  let tablabel = strpart( tablabel, 0, maxlen )
  return tablabel
endfunction


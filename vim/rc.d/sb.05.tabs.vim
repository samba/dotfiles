
" Navigation: Tabs {{{

" TAB NAVIGATION SHORTCUTS {{{
" Shortcut for Tab controls: Control-T - for some reason ths MUST be 'imap', and not 'inoremap'
imap <C-t> <C-o><C-t>


" C-T n: new tab
noremap <silent> <C-t>n :Texplore<CR>
" C-T x: close tab
noremap <silent> <C-t>x :tabclose<CR>
" C-T o: close all other tabs
noremap <silent> <C-t>o :tabonly<CR>
" C-T f: edit the found file(s) in $path, in a new tab (like with :find)
noremap <C-t>f :tabfind<space>
" C-T m: move this tab (followed by a number, index of precedent)
noremap <C-t>m :tabs<CR>:tabm<Space>
" C-T <number>: got to tab specified
noremap <C-t> :tabnext<space>
" next tab
noremap <silent> <C-t><Right> :tabnext<CR>
" previous tab
noremap <silent> <C-t><Left> :tabprevious<CR>
  
" Remember the last tab I was using...
let g:lasttab = 1   " default to the first tab, so it won't complain when there's only one.
autocmd TabLeave * let g:lasttab = tabpagenr()
noremap <silent> <C-t><C-t> :exe 'tabnext' (g:lasttab)<CR>
" }}}

set showtabline=1               "stal:  Display the tabbar if there are multiple tabs. Use :tab ball or invoke Vim with -p

" A nice, minimalistic tabline
" set tabline=%!MyTabLine()
function MyTabLine()
	let s = ''
	for i in range(tabpagenr('$'))
		let hnum = (i + 1)
		" select the highlighting
		if hnum == tabpagenr()
		let s .= '%#TabLineSel#'
		else
		let s .= '%#TabLine#'
		endif

		" set the tab page number (for mouse clicks)
		let s .= '%' . (hnum) . 'T'

		" the label is made by MyTabLabel()
		let s .= ' %{MyTabLabel(' . (hnum) . ')} '
	endfor

	" after the last tab fill with TabLineFill and reset tab page nr
	let s .= '%#TabLineFill#%T'

	" right-align the label to close the current tab page
"	if tabpagenr('$') > 1
"	let s .= '%=%#TabLine#%999Xclose'
"	endif

	return s
endfunction
function MyTabLabel(n)
	let buflist = tabpagebuflist(a:n)
	let winnr = tabpagewinnr(a:n)
	let bname = bufname(buflist[winnr - 1])
	
	let l = fnamemodify(bname, ':~:.')
	return '['.a:n.'] '.l
endfunction

set guitablabel=%{GuiTabLabel()}
function! GuiTabLabel()
	" add the tab number
	let label = '['.tabpagenr()
 
	" modified since the last save?
	let buflist = tabpagebuflist(v:lnum)
	for bufnr in buflist
		if getbufvar(bufnr, '&modified')
			let label .= '*'
			break
		endif
	endfor
 
	" count number of open windows in the tab
	let wincount = tabpagewinnr(v:lnum, '$')
	if wincount > 1
		let label .= ', '.wincount
	endif
	let label .= '] '
 
	" add the file name without path information
	let n = bufname(buflist[tabpagewinnr(v:lnum) - 1])
	let label .= fnamemodify(n, ':t')
 
	return label
endfunction


" }}}


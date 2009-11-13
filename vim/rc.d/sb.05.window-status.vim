"  Window Status line structure {{{

" show - and = to indicate current window
" set fillchars+=stl:=,stlnc:_

" laststatus: show status line? Only if there are at least two windows.
set laststatus=2

" statusline: filename [type] (line:current/total) (column) (line:percent)[(changed)]
" set statusline=%-25.45F\ %-2.9y%=%4l/%-4L\ %3.3v\ %3.3p%%%a%r%m
" set statusline=[%n]\ %<%f%m%r\ %w\ %y\ \ <%{&fileformat}>%=[%o]\ %l,%c%V\/%L\ \ %P
"
set statusline=%!MyStatusLine()
func! MyStatusLine()
	" <buffer number> <filename> <type> <changed> <lines:current/total : %> <column>
    let l:statusline = "[%2n] %-25.45F %=% %9y%6h %3m%r%w L%4l/%-4L:%3p%% C%-3v %-7a"
    return l:statusline
endfunc


" Nice window title
autocmd BufEnter * let &titlestring=expand("%:t")
" set titlestring="%f\ %h%m%r%w\ -\ %{v:progname}\ -\ %{substitute(getcwd(),\ $HOME,\ '~',\ '')}\ [&filetype]"
"set titlestring =%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
" let &titlestring = hostname() . "[vim(" . expand("%:t") . ")]"
" TODO: make this work in screen properly
if &term == "screen"
	set t_ts=^[k
	set t_fs=^[\
endif
if &term == "screen" || &term == "xterm"
	set title
endif


" Nice statusbar"{{{
" set statusline=
" set statusline+=%2*%-3.3n%0*\                " buffer number
" set statusline+=%f\                          " file name
" set statusline+=%h%1*%m%r%w%0*               " flags
" set statusline+=\[%{strlen(&ft)?&ft:'none'}, " filetype
" set statusline+=%{&encoding},                " encoding
" set statusline+=%{&fileformat}]              " file format
" if filereadable(expand("$VIM/vimfiles/plugin/vimbuddy.vim"))
"     set statusline+=\ %{VimBuddy()}          " vim buddy
" endif
" set statusline+=%=                           " right align
" set statusline+=%2*0x%-8B\                   " current char
" set statusline+=%-14.(%l,%c%V%)\ %<%P        " offset
"}}}



" special statusbar for special windows {{{
if has("autocmd")
	au FileType qf
				\ if &buftype == "quickfix" |
				\     setlocal statusline=%2*%-3.3n%0* |
				\     setlocal statusline+=\ \[Compiler\ Messages\] |
				\     setlocal statusline+=%=%2*\ %<%P |
				\ endif

	fun! <SID>FixMiniBufExplorerTitle()
		if "-MiniBufExplorer-" == bufname("%")
			setlocal statusline=%2*%-3.3n%0*
			setlocal statusline+=\[Buffers\]
			setlocal statusline+=%=%2*\ %<%P
		endif
	endfun

	au BufWinEnter *
				\ let oldwinnr=winnr() |
				\ windo call <SID>FixMiniBufExplorerTitle() |
				\ exec oldwinnr . " wincmd w"
endif
" }}}
" }}}



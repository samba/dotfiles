" RULER - the bottom-most line
set ruler 
" set rulerformat=%50(%30.37t\ %n%M%R\ %l,%c\ %3p%%%)
set rulerformat=%15(%n%M%R\ %l,%c\ %3p%%%)


" WINDOW STATUS

" laststatus: show status line? 1: at least two windows; 2: always
set laststatus=1



" set statusline=%!MyStatusLine()
func! MyStatusLine()
  " <buffer number> <filename> <type> <changed> <lines:current/total : %> <column>
  let l:statusline = "[%2n] %-25.45F %=% %9y%6h %3m%r%w L%4l/%-4L:%3p%% C%-3v %-7a"
  return l:statusline
endfunc


" WINDOW TITLE
" Nice window title (compatible with Screen)
autocmd BufEnter * let &titlestring="vim: " . expand("%:t") . " (" . hostname() . ")"
let &titleold=hostname()
if (&term =~ '^screen')
  set t_ts=k
  set t_fs=\
endif
if (&term == "screen" || &term == "xterm")
  set title
endif





" WINDOW SPLITTING
set splitright                  "spr:   puts new vsplit windows to the right of the current
set splitbelow                  "sb:    puts new split windows to the bottom of the current

set winminheight=0              "wmh:   the minimal line height of any non-current window
set winminwidth=0               "wmw:   the minimal column width of any non-current window


" Shortcut for Window controls: Control-W
" use <F2> to cycle through split windows (and <Shift>+<F2> to cycle backwards,
" where possible):
noremap <silent> <F2> <C-W>w
noremap <silent> <S-F2> <C-W>W


" Map C-W for easy switching (even in insert mode)
inoremap <C-w> <C-o><C-w>



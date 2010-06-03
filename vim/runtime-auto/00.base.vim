

" Display non-wrapping line-continues (nowrap set in vimrc-minimal) 
set listchars+=precedes:<,extends:<

" SEARCH
set tagbsearch incsearch " search while typing
nmap .is :set incsearch!<CR>

" Bracket matching
set showmatch matchtime=5

" Cursor Line/Column highlight
set cursorline cursorcolumn

" MOUSE - defaults also in vimrc-minimal
set mouse=nv mousemodel=popup



" For tag navigation... (e.g. in help files)
map <silent><C-Left> <C-T>
map <silent><C-Right> <C-]>



" INDENTATION - defaults set in vimrc-minimal
function ToggleShiftwidth()
	if &shiftwidth == 4
		set shiftwidth=2 tabstop=2 shiftwidth?
	else
		set shiftwidth=4 tabstop=4 shiftwidth?
	endif
endfunction

nmap .TT <Esc>:call ToggleShiftwidth()<CR>

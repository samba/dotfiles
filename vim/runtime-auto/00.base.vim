
set nowrap
set listchars+=precedes:<,extends:<

" Enable per-file formatting and the like
set modeline

" SEARCH
set tagbsearch incsearch

" Bracket matching
set showmatch matchtime=5

" Cursor Line/Column highlight
set cursorline cursorcolumn

" MOUSE
set mouse=n mousemodel=popup


" INDENTATION
set autoindent smartindent 
set tabstop=2 shiftwidth=2

function ToggleShiftwidth()
  if &shiftwidth == 4
    set shiftwidth=2 tabstop=2 shiftwidth? 
  else
    set shiftwidth=4 tabstop=4 shiftwidth?
  endif
endfunction

nmap .TT <Esc>:call ToggleShiftwidth()<CR>

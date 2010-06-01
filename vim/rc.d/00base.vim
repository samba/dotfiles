"""""""""""""""""""""""""""""
" general

syntax on
" colorscheme for terminal
colorscheme rndstr

set nocompatible
filetype on
set history=1000
" to disable auto-folding in latex: filetype plugin off (there should be another way tho, no?)
filetype indent on
set winaltkeys=no
set encoding=utf8
set fileencoding=utf8

""""""""""""""""""""""""""""
" testing
set isk+=_,$,@,%,#,-


""""""""""""""""""""""""""""
" files/backups
set backup " create backups
set backupdir=$HOME/.vim/backup " backup files location
set directory=$HOME/.vim/swap " swap files location

""""""""""""""""""""""""""""
" vim ui

set lsp=0 " space out a little more
set ruler " display ruler
set cmdheight=1 " height of command bar
set number " line numbers are on
set lz " lazyredraw, do not redrawy while running macros
set backspace=2 " make backspace work normal
set showcmd
set scrolloff=4 " keep cursor away from top/bottom


"""""""""""""""""""""""""""""
" visual cues

set showmatch " show matching brackets
set matchtime=5 " how many tenths of a second to blink matahcing brackets for
set statusline=%F%m%r%h%w\ [%{&ff}]\ %y\ (a\%03.3b\ 0x\%02.2B)\ [%04l,%04v]\ %p%%\ (len\ %L)
set laststatus=2 " always show the status line
" display cues :set list 
set lcs=tab:>-,extends:$


"""""""""""""""""""""""""""""
" formatting

" stop continuing comments when switching to insert mode
set formatoptions-=o
let g:PHP_autoformatcomment = 0


"""""""""""""""""""""""""""""
" tabs and indenting
set ai " autoindent
set si " smartindent
set cindent " c-style indenting
set tabstop=2
set shiftwidth=2
set expandtab " no real tabs
set nowrap " no wrapping of lines
" highlight tabs



""""""""""""""""""""""""""""
" apps
set grepprg=grep\ -nH\ $*
 

"""""""""""""""""""""""""""""
" file explorer
let g:explVertical=1
let g:explWinSize=35

""""""""""""""""""""""""""""
" win manager
let g:winManagerWidth=35
let g:winManagerWindowLayout = 'FileExplorer,TagsExplorer|BufExplorer'


""""""""""""""""""""""""""""
" mappings
nmap ,s :source ~/.vimrc<CR>
nmap ,g :source ~/.vimrc<CR>:source ~/.gvimrc<CR>
nmap ,v :tabnew ~/.vimrc<CR>

" remap code completion to Ctrl+Space {{{2
if has("gui")
    " C-Space seems to work under gVim on both Linux and win32
    inoremap <C-Space> <C-n>
else " no gui
  if has("unix")
    inoremap <Nul> <C-n>
  endif
endif

nnoremap <C-n> :set invnumber number?<CR>
nnoremap <C-p> :set invpaste paste?<CR>

function! ToggleShiftwidth()
  if &shiftwidth == 4
    set shiftwidth=2 tabstop=2 shiftwidth? 
  else
    set shiftwidth=4 tabstop=4 shiftwidth?
  endif
endfunction

nnoremap <silent> <C-i> <Esc>:call ToggleShiftwidth()<CR>

""""""""""""""
" uncommenting lines
map ,/ :s/^/\/\//<CR>

" list lines with word under cursor and jump
map ,f [I:let nr = input("line: ")<Bar>exe"normal ".nr."[\t"<CR>

" paste and reformat/reindent
nnoremap <Esc>P P'[v']=
nnoremap <Esc>p p'[v']=

nmap X ci'
" backspace deletes in edit mode
vmap <BS> x

" piece-wise copying of line above current oen
imap <C-L> @@@<Esc>hhkywjl?@@@<CR>P/@@@<CR>3s

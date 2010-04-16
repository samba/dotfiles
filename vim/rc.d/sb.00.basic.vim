filetype plugin indent on
if has('syntax')
        syntax on
endif


set number

set modeline
set foldenable
set autoindent smartindent tabstop=2 shiftwidth=2
set mouse=n mousemodel=popup
"set mouseshape=
set pastetoggle=<F5>
set showmatch tagbsearch incsearch
set tabpagemax=6


set ttyfast
" milliseconds and bytes to wait idle before writing swap
set updatetime=30000 updatecount=100

inoremap  <C-s><C-s> :syn sync fromstart 
nnoremap  <C-s><C-s> :syn sync fromstart 



" set visualbell

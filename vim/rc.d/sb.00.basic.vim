filetype plugin indent on
if has('syntax')
        syntax on
endif


set number
hi LineNr term=italic cterm=NONE ctermfg=DarkGreen ctermbg=none 

set modeline
set foldenable
set autoindent smartindent tabstop=2 shiftwidth=2
set mouse=n mousemodel=popup
"set mouseshape=
set pastetoggle=<F5>
set showmatch tagbsearch incsearch
set splitbelow splitright
set tabpagemax=6


set ttyfast

" seconds and bytes to wait idle before writing swap
set updatetime=10 updatecount=30 

inoremap  <C-s><C-s> :syn sync fromstart 
nnoremap  <C-s><C-s> :syn sync fromstart 



" set visualbell

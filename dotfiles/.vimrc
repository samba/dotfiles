" Vim runtime configuration.
" vim: foldmarker={{(,)}} foldmethod=marker

" Commonly tuned customizations {{{

colorscheme desert

" colorscheme solarized
" let g:solarized_termcolors=256
" let g:solarized_termtrans=1

" This comes first, because we have mappings that depend on leader
" With a map leader it's possible to do extra key combinations
" i.e: <leader>w saves the current file
" let mapleader = ","     " default: \  <backslach>
" let g:mapleader = ","   " default: \  <backslash>

" }}} end common customizations

" Basic environment standardization. {{{=
" this section attempts to implement sensible behavior with simple vim
" settings. no magic. see also:
" https://github.com/jessfraz/.vim/blob/master/vimrc

set backupdir=$HOME/.vim/backup    " backup files location
set directory=$HOME/.vim/swap      " swap files location
set tags=./tags,$HOME/.vim/tags    " you probably want to add more to these later.

" Where to find dictionary words?
" NB this can effect completion settings later.
set dictionary+=/usr/share/dict/words


set noswapfile    " don't use swap files.
set nobackup      " don't create backup files.
set nowritebackup
set nocompatible  " more features please.
set autowrite     " Automatically save before :next, :make etc.

set incsearch     " incremental search - actively find matches while typing
set tagbsearch    " use binary search for tags (:ta) - performance improvement
set ignorecase    " search is case-insensitive (if all lower-case)
set smartcase     " ... but case-sensitive if you type a Capital Letter.
set hlsearch      " highlight search matches
set showmatch matchtime=5  " Show matching parens, brackets, etc (for 5 seconds)


if has('smartindent') " sensible defaults. note that many filetypes tune this below.
    set autoindent smartindent
endif


set tabstop=4     " number of spaces that a tab in a file will render
set shiftwidth=4  " number of spaces for each step of autoindent
set expandtab     " spaces for tabs
set shiftround    " round indentation operations to a multiple of shiftwidth

set splitbelow   " Horizontal windows split below the current window
set splitright   " Vertical windows split right of the current window

set backspace=eol,indent,start

set nocursorcolumn
set nocursorline

set modeline     " Enable per-file configuration lines

set regexpengine=1

set formatoptions=qrn1  " sensible auto-format behavior
" =}}}

" Shortcuts, many toggling above behaviors {{{

" Skip to next blank line
nmap <Leader>k /^\s*$<CR>

" Replacing all instances of the word under cursor
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/

" trim all whitespaces away
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

" Fast saving
nmap <leader>w :w!<cr>

" Toggling a few active behaviors
nmap <leader>Tabs :setlocal et! autoindent! et? ai?<CR>
nmap <leader>Spell :setlocal spell! spell?<CR>

" Remove search highlight
nnoremap <leader><space> :nohlsearch<CR>

" toggles paste mode
nmap <Leader>P :set paste!<CR>

" insert a dot character  (•)
imap <Leader>dot <C-V>u2022

" CTRL-U in insert mode deletes a lot.	Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Disable the macro (complex repeat) feature.
" (The thing that triggers when you accidently type q... in Normal mode.)
map q: :q

inoremap <C-A> <ESC>^i
inoremap <C-E> <ESC>$i


" }}} end shortcuts

" GUI settings {{{
"
if has("gui_running") " See :help guioptions
  set guioptions-=T " Disable toolbar in GUI mode
  set guioptions+=aA " Enable autoselect mode; integrate VIMs buffers with OS paste system, etc
  set guifont=Inconsolata:h15
endif


if has('transparency')
  set transparency=15
endif

" Mouse support always-on in macvim
if has('mouse')
    set mouse=a
    set mousemodel=popup_setpos
endif

" }}} end GUI settings

" GNU screen & terminal title handling {{{
if has('title')
    set titlestring = "vim:\ %t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\%{v:servername}"


	let apple_terminal = (match($TERM_PROGRAM, "Apple_Terminal", 0) == "Apple_Terminal")
	let compat_terminal =  (matchstr(&term, "screen", 0) == "screen" || matchstr(&term, "xterm", 0) == "xterm")

	let g:screen_title = (compat_terminal && !apple_terminal)

    if (g:screen_title)
      set title
      " auto BufEnter * :set title | let &titlestring = &g:titlestring_template
      auto VimLeave * :set t_ts=k\
      set t_ts=k
      set t_fs=\
      set ttymouse=xterm2
    endif
endif

set ttyfast    " optimize for fast terminal connectionss
set lazyredraw " don't update the screen when macros/etc running in background (not command)

" }}}

" VIM's own window structure {{{
"
set fillchars+=vert:\:  " the vertical window barrier's character content

set ruler
set rulerformat=%30(%n\ %Y\ %B\ %=\ %l,%c%V\ %P%)
" set statusline=[%n]\ %f\ -\ %m  " disabled (default)

" statusline is only displayed if there are at least 2 windows.
set laststatus=1




" end VIM window structure }}}

" Tab, Window, and Buffer navigation {{{=
"
" Buffer handling - these are performance improvements.
set switchbuf=useopen           "swb:   Jumps to first window or tab that contains specified buffer instead of duplicating an open window

set nohidden                    " NB: the netrw handling of tree lists doesn't play well with hidden buffers; it ends up writing odd `NetrwTreeListing` files. See related autocmd below.
"set hidden                      "hid:   allows opening a new buffer in place of an existing one without first saving the existing one

" Swap timer: milliseconds and bytes to wait idle before writing swap
set updatetime=30000 updatecount=100


" File buffer navigation
nmap <Leader>n :next<CR>
nmap <Leader>p :prev<CR>

" Easy buffer selection
nmap <Leader>b :ls<CR>:b<Space>


" Tab navigation shortcuts
" noremap <Leader>tex :tabe %:h<CR>  " (disabled) open a new explorer in CWD
noremap <Leader>tex :20Lexplore %:h<CR>
noremap <Leader>tn :tabnext<CR>
noremap <Leader>tp :tabprev<CR>

" if has('browse') or exists('+browse')
" only if the browse flag is enabled at compile (not macOS)
" Open a browser in CWD to select a file
noremap <Leader>tw :browse tabnew .<CR>
" endif


" =}}}

" Text display, wrapping and annotation {{{

" toggle non-printing characters
nmap <Leader>List :set list!<CR>

set nowrap " no wrapping of lines
nmap <Leader>Wrap :set nowrap!<CR>

" Display non-wrapping line-continues
set listchars+=precedes:<,extends:<

" Use this to override keymapping elsewhere if needed
" let mapleader=","
" toggle readonly
nmap <Leader>ro :set invreadonly<CR>


set number " enable line numbering, and a toggle shortcut
nmap <silent> <Leader>Number :set number!<CR>
nmap <silent> <Leader>n :set number!<CR>





if has('syntax')
	syntax on
	syntax sync minlines=256
	set synmaxcol=800

if has('autocmd')
	nmap <Leader>ss :syn sync fromstart<CR>
endif

endif

if has('spell')  " Some filetypes below trigger spelling activation
    set spelllang=en
endif


" }}}


" Plugin handling and related extensions {{{=
"
" exists(...) fails to detect this method's presence, so we just call it.
" In environments where it fails, user can comment it out.

filetype off " required before pathogen

execute pathogen#infect()
execute pathogen#helptags()
execute diff#bind()
execute modelines#bind()
execute comments#bind()

filetype plugin indent on " restore filetype sensibility

" Some plugins I deploy via dotfiles...
" execute comments#MapSlash() " TODO

" Encryption settings {{{
if has('cryptv')
	if has('crypt-blowfish')
		set cryptmethod=blowfish
	endif
	if has('crypt-blowfish2')
		set cryptmethod=blowfish2
	endif
endif
" }}}

" =}}}


" Code folding defaults {{{==

" reference: http://varnit.wordpress.com/2007/10/23/vim-code-folding/

if has('folding')
    set foldenable
    set foldcolumn=4
    set foldmethod=syntax
    nmap <Leader>Fold set foldenable!<CR>

    " In normal mode, Spacebar toggles a fold, zi toggles all folding, zM closes all folds
    nnoremap  <silent>  <space> :execute 'silent! normal! za'.(foldlevel('.')?'':'l')<cr>

    " toggles Presentation mode (e.g. for use in conferences)
	" TODO: switch this to some automatic function...
    nmap <leader>R :set foldmethod=syntax foldcolumn=0 foldenable! number!<CR>

	" Automatic save of folds, so that you dont have to type everytime
	" :mkview to save and :loadview to restore folds
	if has('autocmd')
		autocmd BufWinLeave * silent! mkview
		autocmd BufWinEnter * silent! loadview
	endif

endif

" =}}}


" Completion menu and related {{{

" Ignored filename suffixes
set suffixes+=.in,.a,.bak,.swp,.pyc


""" Default autocomplete methods
" C-X C-L   match similar lines
" C-X C-F   match file names
" C-X C-K   match from dictionary
" C-X C-S   match spelling suggestions
" C-X C-T   match from thesaurus
" C-X C-O   match via Omnicomplete
" C-X C-]   match via tag database
" C-X C-U   match based on user 'completefunc' if defined (or syntax file)
" C-X C-I   match via keywords in include files (see also 'include' and 'path')
" C-X C-N   match keywords in current file
" C-X C-D   match macros & definitions


if has('insert_expand')
	" set completeopt=menu,menuone,,preview,noinsert,noselect
	set completeopt=menu,menuone,longest,noinsert,noselect
	set complete=.,w,b,u,t,i,d


	" enable autocomplete
	set omnifunc=syntaxcomplete#Complete


	set pumheight=12  " number of items shown in the popup menu

endif

if has('wildmenu')
	set wildmenu
	set wildmode=list:longest,list:full

	set wildignore+=*.o,*.obj,*.~,.lo,.so  " compiled object files etc
	set wildignore+=.sw?,.bak       " vim swap files etc
	set wildignore+=.git,.hg,.svn   " version control
	set wildignore+=.DS_Store       " macOS, how tiresome
	set wildignore+=migrations      " Django migrations code (generated)
	set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg  " images
	set wildignore+=go/pkg          " Go packages
	set wildignore+=go/bin          " Go binaries
	set wildignore+=go/bin-vagrant  " Go vagrant files
	set wildignore+=*.pyc           " Python byte code
	set wildignore+=*.orig          " Git's merge resolution cache
endif


" Setup color/style for completion menu {{{
hi Pmenu cterm=none ctermfg=black ctermbg=DarkGreen
hi PmenuSel cterm=none ctermfg=Green ctermbg=black
hi PmenuSbar cterm=bold ctermfg=none ctermbg=Green
hi PmenuThumb cterm=bold ctermfg=Blue ctermbg=black
" }}}



" }}} end Completion menu

" Language-specific (and filetype-specific) settings: {{{

if has('autocmd')  " Most of the per-file functionality requires autocmd.

" Highlight unwanted spaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()



" Sensible per-language defaults.
if has('folding')
	autocmd FileType python setlocal noet foldenable foldmethod=indent
	autocmd FileType javascript setlocal foldenable foldmethod=indent
	autocmd FileType html setlocal foldenable foldmethod=indent
	autocmd FileType help set foldcolumn=0 nonumber foldenable foldmethod=marker "no foldcolumn for help files
endif

" Autocompletion functions, if available...
autocmd FileType sql set omnifunc=sqlcomplete#Complete
autocmd FileType ruby set omnifunc=rubycomplete#Complete
" autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete


" Detect some file types by name
augroup filetypedetect
  au BufNewFile,BufRead .tmux.conf*,tmux.conf* setf tmux
  au BufNewFile,BufRead .nginx.conf*,nginx.conf* setf nginx
  au BufNewFile,BufReadPost *.md setf markdown
  au BufRead   *access.log*  setf httplog
augroup END

" Markdown, YAML and some others need real tabs.
au FileType markdown setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
au FileType yaml setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
au FileType cpp setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
au FileTYpe json setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4

" Disable tab expansion in some commonly stringent formats
au FileType gitconfig setlocal noet
au FileType fstab setlocal noet
au FileType systemd setlocal noet
au FileType dockerfile setlocal noet
au FileType nginx setlocal noet
au FileType go setlocal noet


" Shortcuts and configuration for Go code files
au FileType go setlocal tabstop=4 shiftwidth=4 softtabstop=4
au FileType go nmap <buffer> <Leader>gr <Plug>(go-run)
au FileType go nmap <buffer> <Leader>gb <Plug>(go-build)
au FileType go nmap <buffer> <Leader>gta <Plug>(go-test)
au FileType go nmap <buffer> <Leader>gtf <Plug>(go-test-func)
au FileType go nmap <buffer> <Leader>gtc <Plug>(go-test-compile)
au FileType go nmap <buffer> <Leader>gcv <Plug>(go-coverage)
au FileType go nmap <buffer> <Leader>gcc <Plug>(go-cloverage-toggle)
au FileType go nmap <buffer> <Leader>gl <Plug>(go-lint)
au FileType go nmap <buffer> <Leader>gv <Plug>(go-vet)
au FileType go nmap <buffer> <Leader>gdp <Plug>(go-deps)
au FileType go nmap <buffer> <Leader>gdo <Plug>(go-doc)
au FileType go nmap <buffer> <Leader>gds <Plug>(go-doc-split)

" Go symbol navigation
au FileType go nmap <buffer> <Leader>gs <Plug>(go-def)
au FileType go nmap <buffer> <Leader>gds <Plug>(go-def-split)
au FileType go nmap <buffer> <Leader>gdt <Plug>(go-def-tab)
au FileType go nmap <buffer> <Leader>gds <Plug>(go-def-stack)
au FileType go nmap <buffer> <Leader>gtx <Plug>(go-def-stack-clear)


au FileType go nmap <buffer> <Leader>gti <Plug>(go-implements)
au FileType go nmap <buffer> <Leader>grn <Plug>(go-rename)
au FileType go nmap <buffer> <Leader>gca <Plug>(go-callees)
au FileType go nmap <buffer> <Leader>gcr <Plug>(go-callers)

au FileType go nmap <buffer> <Leader>gdc <Plug>(go-describe)
au FileType go nmap <buffer> <Leader>gcs <Plug>(go-callstack)
au FileType go nmap <buffer> <Leader>gfv <Plug>(go-freevars)
au FileType go nmap <buffer> <Leader>gcp <Plug>(go-channelpeers)
au FileType go nmap <buffer> <Leader>grf <Plug>(go-referrers)
au FileType go nmap <buffer> <Leader>gpt <Plug>(go-pointsto)
au FileType go nmap <buffer> <Leader>gml <Plug>(go-metalinter)
au FileType go nmap <buffer> <Leader>gas <Plug>(go-alternate-split)
au FileType go nmap <buffer> <Leader>gav <Plug>(go-alternate-vertical)

" Calls :GoImport for the current package
au FileType go nmap <buffer> <Leader>gi <Plug>(go-import)
" Calls goimports (CLI) for the current package
au FileType go nmap <buffer> <Leader>gim <Plug>(go-imports)

" Generates an `if err != nil` clause
au FileType go nmap <buffer> <Leader>gie <Plug>(go-iferr)



" Let the enter key take me to navigate help files
autocmd FileType help nmap <buffer> <CR> <C-]>


" Configuration files should permit hex colors
autocmd FileType conf
    \  syn match confColor  "#\x\{2,6}" transparent |
    \  hi def link confColor  String

" Matchit already installed in newer versions of vim.
" Don't need to add this onto pathogen bundle folder. We only need to configure it.
" Configure matchit so that it goes from opening tag to closing tag.
au FileType html,eruby,rb,css,js,xml runtime! macros/matchit.vim

" Activate dictionary completion for text files
if has('spell')
au FileType markdown setlocal complete+=k spell
au FileType gitcommit setlocal complete+=k spell
au FileType text setlocal complete+=k spell
endif


au FileType text setlocal textwidth=78

" Python {{{
" We want consistent spacing in Python, and not tabs.
autocmd FileType python setlocal ai tabstop=4 softtabstop=4 shiftwidth=4 textwidth=80 smarttab expandtab

" And an easy way to check syntax...
autocmd FileType python set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
autocmd FileType python set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m


" }}} end Python


" Javascript {{{
"
" autocmd FileType javascript set makeprg=make\ test
autocmd FileType javascript set makeprg=closure\ --test\ -p\ '%'


" }}} end Javascript

" Makefile {{{
" Makefiles should permit tabs.
autocmd FileType make setlocal noexpandtab
" }}}



endif  " end if has('autocmd') above

" Sensible markdown handling
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'javascript', 'shell=sh']

" For the vim-markdown plugin
let g:vim_markdown_conceal = 0
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_folding_disabled = 0
let g:vim_markdown_follow_anchor = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_toml_frontmatter = 1
let g:vim_markdown_json_frontmatter = 1


" For the vim terraform plugin
let g:terraform_fmt_on_safe = 1
let g:terraform_align = 1

" BASH and similar shell languages {{{
"" :help bash
" let g:is_sh = 1
" let g:is_bash = 1
" let g:is_posix = 1
" let g:is_kornshell = 1
" let g:sh_fold_enabled = {0:none,1:function,2:heredoc,4:if/do/for} (or a sum of them)
let g:sh_fold_enabled=8
let g:sh_minlines=500
let g:sh_maxlines=1000


" end BASH etc }}}

" NetRW File Browser configuration {{{==

" Show tree navigation in Explorer mode
let g:netrw_liststyle = 3
let g:netrw_preview   = 1
let g:netrw_winsize   = 80
let g:netrw_altv      = &spr


" Open files from Explorer view in a new window, split horizontally
let g:netrw_browse_split = 2

" Hide the netrw banner.
let g:netrw_banner    = 0

" Hide dot files and the like by default. (reactivate via `gh`)
let g:netrw_hide      = 1
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+,' . netrw_gitignore#Hide()

" netrw windows should show an abbreviated path for statusline.
if has('statusline') && has('autocmd')
    autocmd filetype netrw setlocal statusline=%(%{pathshorten(getcwd())}%)
endif


" Netrw writes odd files when used in tree listing mode, combined with hidden
" buffers. This attempts to mitigate the problem. See `nohidden` above.
" See also: https://github.com/tpope/vim-vinegar/issues/13
if has('autocmd')
augroup netrw_buf_hidden_fix
    autocmd!

    " Set all non-netrw buffers to bufhidden=hide
    autocmd BufWinEnter *
                \  if &ft != 'netrw'
                \|     set bufhidden=hide
                \| endif

augroup end
endif

" END NetRW File Browser configuration =}}}

" }}} end Language-specific settings



" Development Environment {{{

" Shortcut to run any `make all` in the CWD
map <Leader>m :make<CR>


" QuickFix configuration & shortcuts {{{
" This trigger takes advantage of the fact that the quickfix window can be
" easily distinguished by its file-type, qf. The wincmd J command is
" equivalent to the Ctrl+W, Shift+J shortcut telling Vim to move a window to
" the very bottom (see :help :wincmd and :help ^WJ).
autocmd FileType qf wincmd J

" In the quickfix window, <CR> is used to jump to the error under the
" cursor, so undefine the mapping there.
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>

" Open or Close quickfix easily
nnoremap <leader>q :cwindow<CR>

" Define an "Ag" search command for grepping with eag`
command! -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!

" start grep command  files (shortcut)
nnoremap <Leader>G :Ag<space>

" start built-in grep command
nnoremap <Leader>g :vimgrep!<space>

" grep word under cursor
nnoremap <Leader>K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" Some useful quickfix shortcuts
":cc      see the current error
":cn      next error
":cp      previous error
":clist   list all errors
nmap [q :cn<CR>
nmap ]q :cp<CR>


" }}} end quickfix


" Use The Silver Searcher if present, because it's really fast.
if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  let g:ctrlp_use_caching = 0
endif


" Within a buffer, add this file to the diff
nmap <Leader>D :diffthis<CR>

if &diff
    set cursorline

    " previous change
    nmap ] ]c

    " next change
    nmap [ [c


" diff mode: git merge shortcuts {{
    nmap <leader>0 :diffput MERGE<CR>
    nmap <leader>1 :diffget LOCAL<CR>
    nmap <leader>2 :diffget BASE<CR>
    nmap <leader>3 :diffget REMOTE<CR>
" }}


endif



" }}} end Development environment




" Misc options & key mappings {{{
" NOTE: lots of other key mappings are positioned in this file in their
" relevant groups.


if has('scrollbind')
    " toggle synchronous scrolling of windows
    nmap <Leader>sb :set scrollbind!<CR>
endif

" toggles auto-changedir in Ex mode?
nmap <Leader>CD :set invacd<CR>


" replace all dot characters
function! StripDots()
 execute ":s/^\%U2022/- /"
endfunction


" }}}





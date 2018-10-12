" DEPLOY: 
" wget http://github.com/samba/dotfiles/raw/master/vim/vimrc-minimal -O ~/.vimrc

" This minimal vimrc is intended to be easily deployed to machines where my
" dotfiles are not already installed, while maintaining a basic feature set
" for usability.

" These directories must exist... @{
set backupdir=$HOME/.vim/backup " backup files location
set directory=$HOME/.vim/swap " swap files location
set tags=./tags,$HOME/.vim/tags " you probably want to add more to these later.
" }@

if exists('*pathogen#infect')
  execute pathogen#infect()
endif

colorscheme desert 

set fillchars+=vert:\: 


" Performance @{
set nocompatible

" Swap timer: milliseconds and bytes to wait idle before writing swap
set updatetime=30000 updatecount=100

" Buffer handling
set switchbuf=useopen           "swb:   Jumps to first window or tab that contains specified buffer instead of duplicating an open window
set hidden                      "hid:   allows opening a new buffer in place of an existing one without first saving the existing one

" }@ end Performance


" Misc options & key mappings @{
" NOTE: lots of other key mappings are positioned in this file in their
" relevant groups.

" Use this to override keymapping elsewhere if needed
" let mapleader=","

" File buffer navigation
nmap <Leader>n :next<CR>
nmap <Leader>p :prev<CR>

" Easy buffer selection
nmap <Leader>b :ls<CR>:b<Space>

" toggle readonly
nmap <Leader>ro :set invreadonly<CR>


" noremap <Leader>tex :tabe %:h<CR>
noremap <Leader>tex :20Lexplore %:h<CR>
noremap <Leader>tn :tabnext<CR>
noremap <Leader>tp :tabprev<CR>

" Skip to next blank line
nmap <Leader>k /^\s*$<CR>


" Spelling options (and a shortcut to disable it)
" set spell
set spelllang=en
nmap <Leader>Spell :set spell!<CR>


" toggle synchronous scrolling of windows
nmap <Leader>sb :set scrollbind!<CR>


" toggles paste mode
nmap <Leader>P :set paste!<CR>


" toggles Presentation mode (e.g. for use in conferences)
nmap <leader>R :set foldmethod=syntax foldcolumn=0 foldenable! number!<CR>


" toggles auto-changedir in Ex mode?
nmap <Leader>CD :set invacd<CR>


" insert a dot character
imap <Leader>dot <C-V>u2022

" replace all dot characters
function! StripDots()
 execute ":s/^\%U2022/- /"
endfunction


function! DiffToggle(diffmode)
  if(a:diffmode == 1)
    diffoff
  else
    diffthis
  endif
endfunction

map <silent> <Leader>D :call DiffToggle(&diff)<CR>

map <Leader>m :make<CR>


" }@

" Line wrapping & non-printing chars @{

" toggle non-printing characters
nmap <Leader>List :set list!<CR>


set nowrap " no wrapping of lines
nmap <Leader>Wrap :set nowrap!<CR>

" Display non-wrapping line-continues 
set listchars+=precedes:<,extends:<


" }@

" Window features (statusline, splits, etc) @{

set ruler
set rulerformat=%30(%n\ %Y\ %B\ %=\ %l,%c%V\ %P%)
" set statusline=[%n]\ %f\ -\ %m


" put new windows below and right by default
set splitbelow 
set splitright


" Highlight the current line & column position
" set cursorline cursorcolumn

set number " enable line numbering, and a toggle shortcut
nmap <silent> <Leader>Number :set number!<CR>
nmap <silent> <Leader>n :set number!<CR>


" }@

" Autoindent @{

" toggle auto-indent
set autoindent smartindent
set tabstop=4 shiftwidth=4 expandtab " spaces for tabs, indentation, and avoid real tabs

nmap <Leader>Indent :set autoindent!<CR>
nmap <Leader>Tab :set expandtab!<CR>



" }@

" Search features @{

" For tag navigation... (e.g. in help files)
" map <silent><C-Left> <C-T>
" map <silent><C-Right> <C-]>


" Search settings
set incsearch " incremental search - actively find matches while typing
set tagbsearch " use binary search for tags (:ta) - performance improvement

" Show matching parens, brackets, etc (for 5 seconds)
set showmatch matchtime=5

" }@

" GUI and Mouse Options @{

if has("gui_running") " See :help guioptions
  set guioptions-=T " Disable toolbar in GUI mode 
  set guioptions+=aA " Enable autoselect mode; integrate VIMs buffers with OS paste system, etc
endif


if has('transparency')
  set transparency=15
endif

" Mouse support always-on in macvim
set mouse=a
set mousemodel=popup_setpos

" }@

" Code folding configuration @{
" reference: http://varnit.wordpress.com/2007/10/23/vim-code-folding/
set foldenable
nmap <Leader>Fold set foldenable!<CR>

set foldcolumn=4
set foldmethod=syntax

" In normal mode, Spacebar toggles a fold, zi toggles all folding, zM closes all folds
nnoremap  <silent>  <space> :execute 'silent! normal! za'.(foldlevel('.')?'':'l')<cr>

" Automatic save of folds, so that you dont have to type everytime
" :mkview to save and :loadview to restore folds
autocmd BufWinLeave * silent! mkview
autocmd BufWinEnter * silent! loadview
" }@


" Enable per-file formatting and the like
set modeline

filetype plugin indent on

if has('syntax')
  syntax on
  noremap <silent> <Leader>syn :syn sync fromstart<CR>
endif

" Setup color/style for completion menu @{
hi Pmenu cterm=none ctermfg=black ctermbg=DarkGreen
hi PmenuSel cterm=none ctermfg=Green ctermbg=black
hi PmenuSbar cterm=bold ctermfg=none ctermbg=Green
hi PmenuThumb cterm=bold ctermfg=Blue ctermbg=black
" }@



" Completion menu & such @{

set wildmenu
set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,*.~,.lo,.so,.pyc,.swp,.bak
set suffixes+=.in,.a,.bak,.swp,.pyc

set completeopt=menuone,longest

set pumheight=12

" enable autocomplete
set omnifunc=syntaxcomplete#Complete

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

let g:completion_select_first=0 " config
let g:completion_all_keystrokes=0 " config
let g:completion_active=0 " state

" What keys to use in full automcompletion
let s:keyMapping = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$&>', '.\zs')

function! s:getTokenClassName(pos)
  return synIDattr(synID(line('.'), a:pos - 1, 1), 'name')
endfunction

" Completion inspired by SuperTab
function! SuperCompleter(quicker_mode, minchars, basechar)

  let quickmode = (a:quicker_mode == 1)
  let trailer = g:completion_select_first == 1 ? "\<C-N>" : ''
  let currentline = getline('.') " the line content
  let currentcol = col('.') " position within the line
  let line_precede = strpart(currentline, 0, currentcol +1)
  let word_precede = matchstr(line_precede, "[^ \t]*$") 

  if(strlen(word_precede) > a:minchars)
    if(max([ stridx(word_precede, '/'), stridx(word_precede, '\\') ]) >= 0)
      return "\<C-X>\<C-F>" . trailer " Try completion as filename
    elseif(quickmode)
      return "\<C-X>\<C-I>" . trailer " Try completion as keyword from current & included files (i.e. #include)
    elseif(exists('&omnifunc') && &omnifunc != '')
      return "\<C-X>\<C-O>" . trailer " Try completion via Omnifunc
    elseif(exists('&completefunc') && &completefunc != '')
      return "\<C-X>\<C-U>" . trailer " Try completion via user-mode completion
    else
      return "\<C-X>\<C-D>" . trailer " Try keyword completion from this file
    endif
  endif
  return a:basechar
endfunction

" Use the menu for *everything*
function! s:AllKeystrokesComplete()
  for key in s:keyMapping
    execute printf('inoremap <silent> %s %s<C-r>=SuperCompleter(0,3,"")<CR><C-N><C-P>', key, key)
  endfor
endfunction

function! s:RevokeAllKeystrokes()
  for key in s:keyMapping
    execute printf('iunmap %s', key)
  endfor
endfunction

function! SetupCompletionKeys()
  let g:completion_keys_active=1
 
  " Tab key (with Shift) will step through menu options
  inoremap <expr> <Tab> pumvisible() ? "\<C-N>" : "\<Tab>"
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-P>" : "\<S-Tab>"

  " Enter will use the selected item if one is selected in the menu, when shown,
  " and behave normally (insert new line) when the menu is not shown.
  inoremap <silent> <expr> <CR> pumvisible() ? "\<C-Y>" : "<CR>"

  " Leader-Tab will activate auto-complete in regular mode (file or
  " omni-complete options)
  inoremap <expr> <Leader><Tab> SuperCompleter(0,1,'')

  " Leader-Shift-Tab will activate Definition/Macro completion
  inoremap <expr> <Leader><S-Tab> SuperCompleter(1,1,'')

  if(g:completion_all_keystrokes)
    call s:AllKeystrokesComplete()
  endif

endfunction

function! RevokeCompletionKeys()
  let g:completion_keys_active=0
  iunmap <Tab>
  iunmap <S-Tab>
  iunmap <CR>
  iunmap <Leader><Tab>
  iunmap <Leader><S-Tab>
  if(g:completion_all_keystrokes)
    call s:RevokeAllKeystrokes()
  endif
endfunction

call SetupCompletionKeys()

" Shortcut to toggle completion keys (Leader-C in normal mode)
nnoremap <expr> <Leader>C  (":call " . (g:completion_active == 1 ? "RevokeCompletionKeys" : "SetupCompletionKeys") . "()<CR>")

" }@  end completion 

" NetRW File Browser configuration @{

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

" Start the right-side panel automatically.
"augroup ProjectDrawer 
"  autocmd!
"  autocmd VimEnter * :Vexplore
"augroup END

" netrw windows should show an abbreviated path for statusline.
autocmd filetype netrw setlocal statusline=%(%{pathshorten(getcwd())}%)

" END NetRW File Browser configuration }@



set dictionary+=/usr/share/dict/words

" For BASH and similar shell languages:
" :help bash
" let g:is_sh = 1
" let g:is_bash = 1
" let g:is_posix = 1
" let g:is_kornshell = 1
" let g:sh_fold_enabled = {0:none,1:function,2:heredoc,4:if/do/for} (or a sum of them)
let g:sh_fold_enabled=8
let g:sh_minlines=500
let g:sh_maxlines=1000



" FileType-specific settings @{
autocmd filetype python setlocal noet foldenable foldmethod=indent
autocmd filetype javascript setlocal foldenable foldmethod=indent
autocmd filetype html setlocal foldenable foldmethod=indent

autocmd FileType sql set omnifunc=sqlcomplete#Complete
autocmd FileType ruby set omnifunc=rubycomplete#Complete
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete

" let the enter key take me to navigate help files
autocmd FileType help nmap <buffer> <CR> <C-]>
autocmd FileType help set foldcolumn=0 nonumber foldenable foldmethod=marker "no foldcolumn for help files

" Makefiles should permit tabs.
autocmd FileType make setlocal noexpandtab

" Configuration files should permit hex colors
autocmd FileType conf
    \  syn match confColor  "#\x\{2,6}" transparent |
    \  hi def link confColor  String


" We want consistent spacing in Python, and not tabs.
autocmd FileType python setlocal ai sw=4 ts=4 sta et

" And an easy way to check syntax...
autocmd FileType python set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
autocmd FileType python set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m

" autocmd FileType javascript set makeprg=make\ test
autocmd FileType javascript set makeprg=closure\ --test\ -p\ '%'


" Matchit already installed in newer versions of vim.
" Don't need to add this onto pathogen bundle folder. We only need
" to configure it.
" Configure matchit so that it goes from opening tag to closing tag
au FileType html,eruby,rb,css,js,xml runtime! macros/matchit.vim

" }@




" Automation routines @{

" Shortcut to print PDF with highlights/colors
command! -nargs=* Hardcopy call DoMyPrint('<args>')
function! DoMyPrint(args)
  let colorsave=g:colors_name
  color print
  exec 'hardcopy '.a:args
  exec 'color '.colorsave
endfunction

" }@


" Modeline configuration @{
" This is borrowed (somewhat shamelessly) from:
" https://code.google.com/p/vim-scripts/source/browse/trunk/1352%20Modelines%20Bundle/autoload/modelines.vim
function! GenerateModeline ()
  let l:config = printf(
        \ "%swrap tabstop=%d shiftwidth=%d softtabstop=%d %sexpandtab textwidth=%d "
        \ . "filetype=%s foldmethod=%s foldcolumn=%d", 
        \ (&wrap ? "" : "no"), 
        \ &tabstop,
        \ &shiftwidth,
        \ &softtabstop,
        \ (&expandtab ? "" : "no"),
        \ &textwidth,
        \ &filetype,
        \ &foldmethod,
        \ &foldcolumn
        \ )
  if(&foldmethod == 'marker')
    let l:config = printf('%s foldmarker=%s', l:config, &foldmarker)
  endif
  return printf(&commentstring, " vim: set " . l:config)
endfunction

function! WriteModeline (line)
  let l:line_start = line(".")
  let l:offset = 0
  if a:line > 0
    let l:line = a:line
  else
    let l:line = l:line_start
  endif

  if(0 == strlen(&commentstring))
    return
  endif

  let l:text = getline(l:line)
  let l:modematch = printf(substitute("^".printf(&commentstring," vim: %s")."$",'\*','\\*','g'), '.*')

  let l:prior_view = winsaveview()

  if(strlen(matchstr(l:text, l:modematch)) >0)
    exe ":" . l:line . "d"
    let l:offset = 1
  endif

  call append(l:line - l:offset, GenerateModeline())
  call winrestview(l:prior_view)
endfunction


" Writes a modeline at the last line of the buffer
nmap <Leader>ml :silent call WriteModeline(line("$"))<CR>

" }@

" Sensibly commenting out code blocks... @{

function! LineCommentFlip() range
  let l:parts = split(printf(&commentstring, ' <> '), ' <> ')
  let l:start = parts[0]
  let l:end = (len(parts) > 1) ? parts[1] : ""
 
  for linenum in range(a:firstline, a:lastline)
    let text = getline(linenum)

    " positional indices of comment presence 
    let matchesStart = match(text, escape(l:start, '?*+'), 0)
    let matchesEnd = (len(l:end) > 0) ? match(text, escape(l:end, '?*+'), len(text) - len(l:end)) : -1

    if(matchesStart == -1 && matchesEnd == -1) " comment is absent, so inject it
      call setline(linenum, printf(&commentstring, text))
    else " comment is present, so remove it
      let startSlice = (matchesStart < 0) ? 0 : (matchesStart + len(l:start))
      let endSlice = (matchesEnd < 0) ? len(text) : (matchesEnd - startSlice)
      let result = strpart(text, startSlice, endSlice)
      call setline(linenum, result)
    endif
  endfor
endfunction

command! -range FlipComments <line1>,<line2>call LineCommentFlip()

vmap <silent> <Leader>/ :FlipComments<CR>
nmap <silent> <Leader>/ :FlipComments<CR>


" Automatically load httplog format
autocmd BufRead   *access.log*  setf httplog


autocmd BufNewFile,BufReadPost *.md set filetype=markdown
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'javascript', 'shell=sh']


" }@

" Shortcut for replacing all instances of the word under cursor
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/


" GNU screen & terminal title handling @{
set titlestring = "vim:\ %t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\%{v:servername}"

if (matchstr(&term, "screen", 0) == "screen" || matchstr(&term, "xterm", 0) == "xterm")
  set title
  " auto BufEnter * :set title | let &titlestring = &g:titlestring_template
  auto VimLeave * :set t_ts=k\
  set t_ts=k
  set t_fs=\
  set ttymouse=xterm2
endif
" }@


" .vimrc modeline
" vim: set foldmarker=@{,}@ foldmethod=marker

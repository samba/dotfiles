
function NanoMode () 
	noremap <C-X> :quit<CR>
	noremap <C-O> :write<CR>
	noremap <C-Y> <PageUp>
	noremap <C-V> <PageDown>

	noremap <C-K> dd
	noremap <C-U> p

	noremap <C-W> /
endfunction

if len($NANOMODE) > 0
  call NanoMode()
endif


function EditVimConfig ()
  " open all .vim in the runtime path
  let s:v = $HOME . '/.vim'
  let s:dirs = [ s:v , s:v .'/colors', s:v .'/runtime-auto', s:v .'/runtime-'.hostname() ]
  let s:globs = [ '*.vim', 'vimrc*' ] 
  for @d in s:dirs
    for @g in s:globs
      for @c in split(globpath(@d, @g), '\n')
        exe 'edit ' .@c
       endfor
    endfor
  endfor
endfunc

if len($EDITVIM) > 0
  call EditVimConfig()
endif

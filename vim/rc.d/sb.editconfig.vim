
function EditVimConfig ()
	" open all .vim in the runtime path
	for conf in split(globpath(&runtimepath, '*.vim'), "\n")
		exe "edit ".conf
	endfor
	" open vimrc itself
	edit ~/.vimrc
endfunc

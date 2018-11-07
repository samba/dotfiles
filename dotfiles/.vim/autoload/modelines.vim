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


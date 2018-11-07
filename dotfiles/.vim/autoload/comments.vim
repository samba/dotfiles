
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

function! MapSlash() 
vmap <silent> <Leader>/ :FlipComments<CR>
nmap <silent> <Leader>/ :FlipComments<CR>
endfunction

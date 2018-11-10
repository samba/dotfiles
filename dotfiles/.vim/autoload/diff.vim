
function! DiffToggle(diffmode)
  if(a:diffmode == 1)
    diffoff
  else
    diffthis
  endif
endfunction



function! diff#bind() abort
    " Toggle the diff mode setting.
    map <silent> <Leader>D :call DiffToggle(&diff)<CR>
endfunction


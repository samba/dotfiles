
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

    " Within a buffer, add this file to the diff
    " nmap <Leader>D :diffthis<CR>

    if &diff  " the current buffer is in diff mode
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

endfunction



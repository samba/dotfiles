set ttyfast

" milliseconds and bytes to wait idle before writing swap
set updatetime=30000 updatecount=100

set switchbuf=useopen           "swb:   Jumps to first window or tab that contains specified buffer instead of duplicating an open window
set hidden                      "hid:   allows opening a new buffer in place of an existing one without first saving the existing one


" Delete a buffer but keep layout
if has("eval")
  command! Kwbd enew|bw #
  nmap     <C-w>!   :Kwbd<CR>
endif


" Navigation: general buffer handling {{{

set switchbuf=useopen           "swb:   Jumps to first window or tab that contains specified buffer instead of duplicating an open window
set hidden                      "hid:   allows opening a new buffer in place of an existing one without first saving the existing one

" BUFFER NAVIGATION SHORTCUTS"{{{
" *** F1 provides a list of open files; see Function Key Shortcuts.
" Delete a buffer but keep layout
if has("eval")
    command! Kwbd enew|bw #
    nmap     <C-w>!   :Kwbd<CR>
endif

" Type <F1> follwed by a buffer number or name fragment to jump to it.
" Also replaces the annoying help button. Based on tip 821.
noremap <F1> :ls<CR>:b<Space>
" ... I prefer control-F
noremap <C-F> :ls<CR>:b<Space>

" File Switching use <C-N> & <C-P> to cycle through files {{{
"" SHORTCUTS
nnoremap <C-N> :next<CR>
nnoremap <C-P> :prev<CR>
" [<Ctrl>+N by default is like j, and <Ctrl>+P like k.]

"}}}


"}}}


"}}}

noremap <C-E> :tabnew<CR>:Explore<CR>


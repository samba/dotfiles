
" Markdown needs spaces, not tabs
setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4 formatoptions+=t

" Activate dictionary completion for text files
if has('spell')
    setlocal complete+=k spell
endif

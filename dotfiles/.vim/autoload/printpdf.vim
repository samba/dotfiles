
" Shortcut to print PDF with highlights/colors
if has('printer')
    command! -nargs=* Hardcopy call DoMyPrint('<args>')
    function! DoMyPrint(args)
      let colorsave=g:colors_name
      color print
      exec 'hardcopy '.a:args
      exec 'color '.colorsave
    endfunction
endif


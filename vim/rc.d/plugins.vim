" prolly should move this to ~/.vim/after/plugin/ ?

""""""""""""""""""""""""
" NERD_tree.vim
" http://www.catonmat.net/blog/vim-plugins-nerdtree-vim/


map <F8> :NERDTreeToggle<CR>


""""""""""""""""""""""""
" taglist.vim
let Tlist_Ctags_Cmd = "/usr/bin/exuberant-ctags"
let Tlist_Inc_Winwidth = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_File_Fold_Auto_Close = 1
let Tlist_Process_File_Always = 1
let Tlist_Enable_Fold_Column = 0
let tlist_php_settings = 'php;c:class;d:constant;f:function'
nmap <silent> <F7> :TlistToggle<CR>


""""""""""""""""""""""""
" surround.vim


"  Old text                  Command     New text ~
"  print "Hello *world!"     yss-        <?php print "Hello world!" ?>

autocmd FileType php let b:surround_45 = "<?php \r ?>"



"""""""""""""""""""""""""""
" plugin/DoxygenToolkit.vim

nnoremap <C-x> :Dox<CR>

let g:DoxygenToolkit_briefTag_pre=""
let g:DoxygenToolkit_authorName="Roland Schilter"
" set empty for non c++ files
let g:DoxygenToolkit_commentType=""

let g:DoxygenToolkit_licenseTag="Copyright (C) 2010 Roland Schilter <mail@rolandschilter.ch>\<enter>\<enter>"
let g:DoxygenToolkit_licenseTag=g:DoxygenToolkit_licenseTag . "This program is free software; you can redistribute it and/or modify\<enter>"
let g:DoxygenToolkit_licenseTag=g:DoxygenToolkit_licenseTag . "it under the terms of the GNU General Public License as published by\<enter>"
let g:DoxygenToolkit_licenseTag=g:DoxygenToolkit_licenseTag . "the Free Software Foundation; either version 2 of the License, or\<enter>"
let g:DoxygenToolkit_licenseTag=g:DoxygenToolkit_licenseTag . "(at your option) any later version.\<enter>\<enter>"
let g:DoxygenToolkit_licenseTag=g:DoxygenToolkit_licenseTag . "This program is distributed in the hope that it will be useful,\<enter>"
let g:DoxygenToolkit_licenseTag=g:DoxygenToolkit_licenseTag . "but WITHOUT ANY WARRANTY; without even the implied warranty of\<enter>"
let g:DoxygenToolkit_licenseTag=g:DoxygenToolkit_licenseTag . "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\<enter>"
let g:DoxygenToolkit_licenseTag=g:DoxygenToolkit_licenseTag . "GNU General Public License for more details.\<enter>\<enter>"
let g:DoxygenToolkit_licenseTag=g:DoxygenToolkit_licenseTag . "You should have received a copy of the GNU General Public License\<enter>"
let g:DoxygenToolkit_licenseTag=g:DoxygenToolkit_licenseTag . "along with this program; if not, write to the Free Software\<enter>"
let g:DoxygenToolkit_licenseTag=g:DoxygenToolkit_licenseTag . "Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.\<enter>"

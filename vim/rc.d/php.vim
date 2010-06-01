" documentation
set runtimepath+=~/.vim/php
" unset so K defaults to :help
set keywordprg=
"
" exuberant-ctags
nmap <silent> ,t
  \ :!exuberant-ctags -f ./tags
  \ --langmap="php:+.inc"
  \ -h ".php.inc" -R --totals=yes
  \ --tag-relative=yes --PHP-kinds=+cf-v .<CR>
set tags=./tags,tags

iab techo <?php echo ?><Left><Left><Left>

#!/bin/bash

# vim integration


# cleanup
keepdays=15 # days to keep
find ${HOME}/.vim/view -type f -mtime +${keepdays} -print -delete >> ${HOME}/.vim/view/deletion.log


# VIM-ness - some friendly shortcuts {{{
alias :q='exit'		
alias :s='history -a'	# save the shell history
alias :m='pushd'	# store a path
alias :d='popd'		# pop a path
alias :marks='dirs -v'	# show all paths
# }}}


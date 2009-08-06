#!/bin/bash
# SPELLING AND AUTO-COMPLETE {{{
# correct spelling mistakes
shopt -s cdspell

# look at variables that might hold directory paths
# shopt -s cdable_vars

# tab-completion of hostnames after @
shopt -s hostcomplete

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

if [ -f /etc/profile.d/bash-completion.sh ]; then
    source /etc/profile.d/bash-completion.sh
fi


# }}}


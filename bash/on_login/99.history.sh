#!/bin/bash
# HISTORY {{{ 

# also write command history at every prompt.
PROMPT_COMMAND=" history -a; ${PROMPT_COMMAND} "


# don't put duplicate lines in the history. See bash(1) section 'HISTORY' for more options
export HISTCONTROL="ignoredups"

# ... and ignore same sucessive entries, as well as commands starting with a space.
export HISTCONTROL="ignoreboth" 

# store more stuff in the history...
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTTIMEFORMAT="[%F-%T] " # puts full date and time in history display.

# ignore relatively meaningless commands.
export HISTIGNORE="fg*:bg*:history*"

shopt -s histappend # makes bash append to history rather than overwrite

# store multiline commands as single entries in history file
shopt -s cmdhist

# allow re-editing of a history command substitution, if the previous run failed
shopt -s histreedit


if [ -n $BASH_SESSION_PATH ]; then
    d=`date +%s` 
    # save the history if a session path is defined.
    gzip -c $HISTFILE > $BASH_SESSION_PATH/history.`hostname`.$d.gz
    
    keep=30 log=$BASH_SESSION_PATH/history.deletion.log
    # clean out those older than specified time...
    find $BASH_SESSION_PATH/ -name history.`hostname`.*.gz -mtime +$keep -print -delete >> $log
fi


# }}}


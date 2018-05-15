#!/usr/bin/env bash


export PS_FORMAT="pid,ppid,state,%cpu,%mem,euser:15,command"


if ls --color >/dev/null 2>/dev/null ; then  # GNU/Linux
  which dircolors >/dev/null && eval "$(dircolors -b)"
  export LS_OPTIONS="--color=auto"
else # MacOS or some BSD
  export LS_OPTIONS="-G"
  export LSCOLORS='gxfxcxdxbxegedabagacad'
fi

export LS_OPTIONS="${LS_OPTIONS} -pF"

alias ls='ls $LS_OPTIONS'
alias la='ls $LS_OPTIONS -alh'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -CF'


alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias j='jobs -l'
alias d='dirs -l -v'


case `which hd` in
  *hd) break ;; # it exists!
  *) command -v hd > /dev/null || alias hd="hexdump -C" ;;
esac

case `which md5sum md5` in
  *md5) alias md5sum="md5 -r";; # BSD/OS X compatibility with Linux environs
esac


case `which mvim` in
  *mvim)
    export MVIM_SERVER="VIM$$"
    alias tvim='mvim --servername ${MVIM_SERVER} --remote-tab-silent'
  ;;  
esac

# Shortcut for encrypted VIM sessions
alias xvim='vim -x'


# Easily trigger Python's debugger...
alias pdb='python -m pdb'

# URL-encode strings
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

for f in $( # Some useful built-ins from Apple

  # A javascript interpreter
  echo '/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc'
);  do
  test -e "$f" && alias $(basename $f)="$f"
done


# Ring the bell after a long running command, 
# e.g. > cp bigfile /mnt/destination && bell
alias bell="tput bel"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'
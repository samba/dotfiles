#!/usr/bin/env bash


if which ps >/dev/null && ps -L | tr -s ' ' '\n' | grep -q euser ; then
  # The GNU default mode...
  export PS_FORMAT="pid,ppid,state,%cpu,%mem,euser:15,command"
else 
  # BSD ps doesn't support euser, etc.
  export PS_FORMAT="pid,ppid,state,%cpu,%mem,user,command"
  alias ps='ps -o $PS_FORMAT'
fi


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


if which xclip >/dev/null; then
  test -x "$(which pbcopy)" || alias pbcopy='xclip -selection clipboard'
  test -x "$(which pbpaste)" || alias pbpaste='xclip -selection clipboard -o'
fi

if which vim >/dev/null; then
    # Shortcut for encrypted VIM sessions
    alias xvim='vim -xn'
    alias notes='vim ~/Notes'
fi

# Easily trigger Python's debugger...
alias pdb='python -m pdb'

# Pop a new screen session in the current directory.
alias screendupe='screen bash -c "cd $PWD; exec ${SHELL} --login -i"'

# URL-encode strings
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

for f in $( # Some useful built-ins from Apple

  # A javascript interpreter
  echo '/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc'
);  do
  test -e "$f" && alias $(basename $f)="$f"
done


case $(uname -s) in 
  Darwin)  ### Aliases that only make sense on a Mac.
      
    if which lwp-request >/dev/null; then
      for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
        alias "$method"="lwp-request -m '$method'"
      done
      unset method
    fi


    # Settings control for MacOS
    alias plist="/usr/libexec/PlistBuddy"

    # Lock screen
    alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"


    # Toggle the Desktop search engine
    alias mac_disable_spotlight="sudo mdutil -a -i off"
    alias mac_enable_spotlight="sudo mdutil -a -i on"

    # Toggle the Desktop icons
    alias mac_show_desktop="defaults write com.apple.finer CreateDesktop -bool true && killall Finder"
    alias mac_hide_desktop="defaults write com.apple.finer CreateDesktop -bool false && killall Finder"

    # Toggle hidden files in the Finder file browser
    alias mac_show_hidden_files="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
    alias mac_hide_hidden_files="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

  ;;
esac


# Use colored diff by Git when available.
# Inspired by https://github.com/jessfraz/dotfiles/blob/master/.functions
if which git >/dev/null; then
  alias diff="git diff --no-index --color-words"
  alias g="git"
fi



# Ring the bell after a long running command, 
# e.g. > cp bigfile /mnt/destination && bell
alias bell="tput bel"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'


# Encryption shortcuts
alias encrypt="openssl aes-256-cbc -e";
alias decrypt="openssl aes-256-cbc -d";


# Kubernetes
alias k='kubectl'
alias kpo='kubectl get pods -o wide'
alias ksvc='kubectl get services -o wide'
alias kdep='kubectl get deployments -o wide'
alias knod='kubectl get nodes -o wide'
alias ktail='kubectl log -f'

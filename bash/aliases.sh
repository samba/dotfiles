alias dotfiles="git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles"

alias distccmon="DISTCC_DIR=/var/tmp/portage/.distcc distccmon-text 1"

# --- browsing and shell and tool options ---
? () { echo "scale=3; $*" | bc -l; }

alias ls="ls -Fh --color=auto" # default ls options
alias la="ls -la"
alias l="ls -l"
alias lls="ls -lSr" # sort by size reverse
alias llt="ls -ltr" # sort by time reverse
alias ,="cd .."
alias ,,='cd .. && ls -l'
alias du="du -sh"

alias grep="grep --color=auto"
alias less="less -r" # colorize
alias more="more -r" # colorize

alias h="history | grep -i" # or use ctrl-r
alias hclear='history -c; clear'

alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"
alias vi='vim -X -p'
alias vim='vim -X -p'
alias svnd="svn diff | less"


# set $HOME of target user
alias sudo="sudo -H"

alias s="screen"
alias ss="screen -S "
alias sl="screen -list"
alias sr="screen -d -r"
alias sx="screen -x"

which colordiff >/dev/null && alias diff='colordiff'


# --- processes ---
which htop >/dev/null && alias top='htop'
export PS_FORMAT="pid,ppid,state,%cpu,%mem,euser:15,command"
alias psg="ps -awef |grep"

#
alias :q='exit'



# --- mplayer ---
# no audio
alias amplayer="mplayer -nosound"
alias cmplayer="mplayer -cache 5000"
alias pmplayer="mplayer -playlist"
# ffmpeg deinterlace
alias dmplayer="mplayer -vf pp=fd"

# play on second screen
alias mplayer1="mplayer -xineramascreen 1 -monitoraspect 4:3"
alias mplayer1shuffle="mplayershuffle -xineramascreen 1 -monitoraspect 4:3"

alias eptlive="mplayer http://stream-eng.pokerstars.tv/pxpkrlive-live/pokerstarslive_eng_500k"
# &record
alias reptlive="mplayer http://stream-eng.pokerstars.tv/pxpkrlive-live/pokerstarslive_eng_500k -dumpstream -dumpfile"



# --- some functions ---
function fbup { while [ $# -gt 0 ]; do cp -i "$1" "$1-"; shift; done; }

function TODO() { echo $* >> $HOME/.TODO; }

# open all matching files with editor
function grepvi() { $EDITOR $(grep $* * | cut -d : -f 1 | uniq); }

# excludes .svn matches
function grepsvn() { grep -R $* * | grep -v \.svn ; }

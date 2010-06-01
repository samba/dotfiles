
alias cdn="cd /10movie/BT/noseed"
alias cdu="cd /10movie/BT/upload"
alias leech="cd /pub/leech && wget"
alias leechmp3="cd /pub/leech/mp3 && wget"

alias vncfinkpad="vncviewer -compresslevel 9 -quality 9 10.0.0.20"

function addeng() { echo $* >> $SHAD_HOME/.ENGLISH; }

# --- devtodo ---
if [[ -x /usr/bin/devtodo && -n "$SHAD_HOME" ]]; then
  # global mode for devtodo
  #alias gtodo="todo -g ~/.todo_global -G"

  # real todo, pc stuff
  alias ptodo="todo --global-database $SHAD_HOME/.todo_pc -G"

  # reminder for repeating commands
  alias rtodo="todo --global-database $SHAD_HOME/.todo_remind -G"
fi

# --- find ---
alias fmp3="cat /pub/mp3/.mp3listing | grep -i"
function fmovie() {
  cat /pub/.movielisting* | grep -i $*
  lsre -ld /07movie 0 -ld /07movie/ARCHIVE/ 1 | grep -i $*
  lsre -ld /08movie 0 -ld /08movie/ARCHIVE/ 1 | grep -i $*
  lsre -ld /09movie 0 -ld /09movie/ARCHIVE/ 1 | grep -i $*
}


# --- ftp ---

# Upload file to plrf.org
function sendplrf() {
  ncftpput -f $SHAD_HOME/.ncftp/plrf.org_public.cfg / $*
  echo " ------------------"
  for i in $*
  do
    echo "http://plrf.org/pub/`basename $i`"
  done
}

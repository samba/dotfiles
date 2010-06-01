# Usage: <videofile>
mplayerscreenies () {
  (for i in $(seq 1 7 100); do echo -e "seek $i 1\nscreenshot 0\n"; done; echo "quit") | \
  mplayer -quiet -slave -vf screenshot "$1"
}



alias use="cat /usr/portage/profiles/use.desc | grep"

istop () { sudo /etc/init.d/$1 stop; }
istart () { sudo /etc/init.d/$1 start; }
irestart () {  sudo /etc/init.d/$1 restart; }
istatus () { sudo /etc/init.d/$1 status; }

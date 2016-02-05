#!/bin/sh

### Installer for our workspace tools & configuration
# Oriented to Mac OS X (and compatible with Linux where possible)

# import backup utils/etc
# provides userdata cache and restore methods
. setup-scripts/prepare.sh
. setup-scripts/downloads.sh
. setup-scripts/dotfiles.sh
. setup-scripts/python.sh
. setup-scripts/vim.sh
. setup-scripts/sshkeygen.sh

DOWNLOADING=0

main () {
  for MODE in "$@"; do
    case $MODE in
      downloads)
        DOWNLOADING=1;
        queue_downloads;
        ;;
      dotfiles)
        setup_dotfiles;
        setup_vim;
        ;;
      
      environ)
        install_python_environment;
        setup_sshkeys;
        ;;
      all)
        main downloads;
        main environ;
        main dotfiles;
        ;;
    esac

  done

  # If no option is given
  if [ $# -lt 1 ]; then
    setup_dotfiles;
  fi



}


cache_userdata > /tmp/workspace-setup.conf

main "$@"

restore_userdata < /tmp/workspace-setup.conf

[ ${DOWNLOADING} -eq 1 ] && echo "# Waiting for downloads to finish..." >&2
wait;

# rm /tmp/workspace-setup.conf

#!/bin/sh

### Installer for our workspace tools & configuration
# Oriented to Mac OS X (and compatible with Linux where possible)

# import backup utils/etc
# provides userdata cache and restore methods
. setup-scripts/prepare.sh
. setup-scripts/downloads.sh
. setup-scripts/dotfiles.sh
. setup-scripts/python.sh


DOWNLOADING=0

cache_userdata > /tmp/workspace-setup.conf

for mode; do
  case $mode in
    downloads)
      DOWNLOADING=1;
      queue_downloads;
      ;;
    dotfiles)
      setup_dotfiles;
      ;;
    all)
      DOWNLOADING=1;
      queue_downloads;
      setup_dotfiles;
      install_python_environment;
      ;;
  esac
done

# If no option is given
if [ $# -lt 1 ]; then
  setup_dotfiles;
fi


restore_userdata < /tmp/workspace-setup.conf

[ ${DOWNLOADING} -eq 1 ] && echo "# Waiting for downloads to finish..." >&2
wait;

# rm /tmp/workspace-setup.conf

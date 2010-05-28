#!/bin/bash

# goal: a rather forceful way of enabling remote desktop with a known configuration

# disable requiring local confirmation
gconftool-2 -s -t bool /desktop/gnome/remote_access/prompt_enabled false

# set remote control (not view only)
gconftool-2 -s -t bool /desktop/gnome/remote_access/view_only false

# let the local session continue after I'm gone...
gconftool-2 -s -t bool /desktop/gnome/remote_access/lock_screen_on_disconnect false

# optionally set a different port
read -p "VNC Listening Port (standard: 5900; blank: don't set the alternative): " port;
if [ -z "$port" ]; then
  gconftool-2 -s -t bool /desktop/gnome/remote_access/use_alternative_port false
else
  gconftool-2 -s -t int /desktop/gnome/remote_access/alternative_port $port
  gconftool-2 -s -t bool /desktop/gnome/remote_access/use_alternative_port true
fi


# enable password auth
read -p "VNC Password (required): " -s password;
gconftool-2 -t list --list-type string -s /desktop/gnome/remote_access/authentication_methods '[vnc]'
gconftool-2 -t string -s /desktop/gnome/remote_access/vnc_password "$(echo "$password" | base64)"


# enable remote desktop
gconftool-2 -s -t bool /desktop/gnome/remote_access/enabled true


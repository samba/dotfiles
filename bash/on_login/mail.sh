#!/bin/bash
# MAIL {{{
# set the mail location, notification options
MAILPATH="/var/mail/${USER}?You have mail:~/.mbox?$_ has mail!"

# keep an eye on the mail files (access time)
shopt -s mailwarn
# }}}


# TODO: a function to send a file as an attachment 

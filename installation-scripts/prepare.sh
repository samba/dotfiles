#!/bin/sh

mkdir -p ${HOME}/.dotfiles/bin

cache_userdata () {
  
  git_user="`git config --global --get user.name`"
  git_email="`git config --global --get user.email`"
  github_user="`git config --global --get github.user`"
  github_email="`git config --global --get github.email`"
  github_token="`git config --global --get github.token`"

  echo "git restore user.name ${git_user}" 
  echo "git restore user.email ${git_email}"
  echo "git restore github.user ${github_user}"
  echo "git restore github.email ${github_email}"
  echo "git restore github.token ${github_token}"

}

restore_userdata () {
  while read mode action attrib value; do
    case $mode in
      git)
        case $action in
          restore)
            git config --global ${attrib} "${value}";;
        esac
        ;;
    esac
  done
}

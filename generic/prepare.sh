#!/usr/bin/env bash


# Generate a static script that restores the proper git config.
# This will make recovery easier in the event that a task somewhere else in this process fails.
populate_params_stash () {
cat >> ${2} <<EOF
#!/usr/bin/env sh
# Stashed properties from ~/.gitconfig
GIT_USER_NAME="$(git config -f $1 --get user.name)"
GIT_USER_EMAIL="$(git config -f $1 --get user.email)"
GITHUB_USER="$(git config -f $1 --get github.user)"
GITHUB_EMAIL="$(git config -f $1  --get github.email)"
GITHUB_TOKEN="$(git config -f $1  --get github.token)"
GIT_SIGNING_KEY="$(git config --global --get user.signingkey)"
GIT_SIGN_COMMITS="$(git config --global --get commit.gpgsign)"


if test -f \$1; then
  git config -f \$1 user.name "\${GIT_USER_NAME}"
  git config -f \$1 user.email "\${GIT_USER_EMAIL}"
  git config -f \$1 user.signingkey "\${GIT_SIGNING_KEY}"
  git config -f \$1 commit.gpgsign "\${GIT_SIGN_COMMITS}"
  git config -f \$1 github.user "\${GITHUB_USER}"
  git config -f \$1 github.email "\${GITHUB_EMAIL}"
  git config -f \$1 github.token "\${GITHUB_TOKEN}"
else 
  echo "Could not find Git config file \$1" >&2
fi
EOF
}

restore_params_config () {
    if test -f $2; then
      echo "Restoring Git configuration $2 > $1" >&2
      bash -x $2 $1
    else
      echo "Could not find gitconfig restore script: $2" >&2
      return 1
    fi
}

setup_ssh_keys () {
    test -d ~/.ssh || mkdir -m 0700 ~/.ssh
    test -f ~/.ssh/id_rsa && return 0
    echo "Preparing an SSH key..." >&2
    ssh-keygen -f ~/.ssh/id_rsa -C "${USER}@`hostname`" -b 4096

    # also setup common SSH paths
    mkdir -p ~/.ssh/keys ~/.ssh/sock
}

wipeout_previous_cache () {
  mkdir -p ${HOME}/.cache
  rm -rvf ${HOME}/.cache/bash
}



main () {

    path="$1";
    mode="$2";
    target="$path/.gitconfig"

    temp="${HOME}/.temp/gitconfig.`date +%Y%m%d-%H`"
    mkdir -p "${HOME}/.temp"

    case "$mode" in
        prepare) 
            test -f "$target" && populate_params_stash "$target" "$temp"
            setup_ssh_keys
            test "${KEEP_CACHE}" -eq 1 || wipeout_previous_cache
        ;;
        restore) 
            test -f "$target" && restore_params_config "$target" "$temp"
        ;;
        clean)
            rm -rvf "$temp"
        ;;

        *)
            echo "(nothing for prepare.sh w/ ${mode})" >&2
        ;;
    esac
}

main "${@}"

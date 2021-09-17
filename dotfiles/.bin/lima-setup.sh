#!/bin/bash

echo "Setting up lima VM config"

command -v limactl || exit 1
command -v lima || exit 1

# creates the VM if not exist
limactl start default


limactl cp ${HOME}/.screenrc default:.screenrc
limactl cp ${HOME}/.vimrc default:.vimrc

# Copy in VM context from mounted home
lima cp -v ${HOME}/.bashrc \${HOME}/.bashrc

for i in $(ls -1 ${HOME}/.bash_* | grep -v history); do
    test -f $i && limactl cp $i default:$(basename $i)
done

# to support rootless containers, the Linux host must define XDG_RUNTIME_DIR correctly.
limactl shell default sudo loginctl enable-linger $(whoami)


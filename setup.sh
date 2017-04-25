#!/bin/sh

# Sets up a wide array of my development environment on a Mac...

export PATH="/usr/local/bin/:${PATH}"

fail(){
  err=$1; shift 1;
  echo "$@" >&2
  exit $err
}

requires(){ # simple wrapper to check presence of executables.
  which $@ >/dev/null
}


setup_homebrew () {
  requires xcodebuild || return $?
  requires sudo || return $?

  sudo xcodebuild -checkFirstLaunchStatus
  [ $? -eq 69 ] || sudo xcodebuild -license

  requires brew && return 0  # already installed

  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

}

setup_containerkit (){
  requires brew || return $?
  sudo mkdir -p /etc/{kubernetes,docker}


  brew install \
    docker docker-completion \
    docker-compose docker-compose-completion \
    docker-machine docker-machine-completion \
    xhyve docker-machine-driver-xhyve \
    docker-machine-nfs docker-clean \
    kubernetes-cli compose2kube

  brew install Caskroom/cask/minikube

  # Start virtual machines if not present.
  docker-machine status docker-default | grep -v Running && docker-machine create -d xhyve docker-default
  minikube status | grep -v Running && minikube start --vm-driver xhyve

  docker_env=`mktemp /tmp/dockerenv.sh.XXXXX`
  kubernetes_env=`mktemp /tmp/kubernetesenv.sh.XXXXX`


  echo 'eval $(docker-machine env docker-default)' > ${docker_env}
  echo 'eval $(minikube docker-env)' > ${kubernetes_env}

  sudo mv ${docker_env} /etc/docker/env.sh
  sudo mv ${kubernetes_env} /etc/kubernetes/env.sh

}

setup_hashicorp (){
  requires brew || return $?
  brew install \
    Caskroom/cask/vagrant{,-manager} \
    vagrant-completion \
    terraform
}

setup_nodedev () {
  requires brew || return $?
  brew install node phantomjs
  npm install -g \
    growl \
    {babel,gulp,grunt}-cli \
    gyp \
    nyc istanbul \
    jshint eslint \
    mocha \
    node-sass \
    google-closure-compiler-js
}


setup_python_base () {
  requires easy_install || $?
  sudo easy_install pip
  sudo pip install --upgrade --ignore-installed six python-dateutil
}

setup_pythondev () {
  requires brew || return $?
  requires pip || return $?
  brew install python3
  sudo -H pip install \
    virtualenv vex \
    coverage nose unittest2 \
    pep8 pyflakes flake8 \
    vboxapi \
    Jinja2 Pillow \
    lesscpy
}

setup_cloud_services (){
  requires brew || return $?
  requires pip || return $?
  brew install \
    Caskroom/cask/google-cloud-sdk
  sudo -H pip install \
    google-api-python-client \
    awscli awslogs
}

setup_system_libs () {
  requires brew || return $?
  brew install \
    libffi libgit2 \
    openssl wget \
    jpeg
}

setup_database (){
  requires brew || return $?
  brew install \
    mysql mongodb postgresql \
    Caskroom/cask/mongohub \
    Caskroom/cask/mysqlworkbench \
    Caskroom/cask/robomongo \
    Caskroom/cask/mongodbpreferencepane

  mkdir -p ~/Library/LaunchAgents
  cp `brew --prefix mysql`/*mysql*.plist ~/Library/LaunchAgents/
  launchctl load -w ~/Library/LaunchAgents/*mysql*.plist
}


setup_userkit () {
  # User environment
  requires brew || return $?
  brew install \
    Caskroom/cask/iterm2 \
    Caskroom/cask/macdown \
    Caskroom/cask/cyberduck \
    Caskroom/cask/postman \
    Caskroom/cask/fork \
    Caskroom/cask/viscosity \
    Caskroom/cask/transmission \
    Caskroom/cask/veracrypt \
    terminal-notifier
}


setup_remoteauth () {
  mkdir -m 0700 ~/.ssh
  [ -f ~/.ssh/id_rsa ] || ssh-keygen -f ~/.ssh/id_rsa -C "${USER}@${HOSTNAME}" -b 4096
}



setup_homebrew || fail $? "Could not set up homebrew."
setup_python_base || fail $? "Could not prepare Python base environment."
setup_system_libs || fail $? "Could not install dependent libraries."
setup_containerkit || fail $? "Could not setup Docker and/or Kubernetes."
setup_hashicorp || fail $? "Could not setup terraform or vagrant."
setup_userkit || fail $? "Could not set up user environment utilities."
setup_remoteauth || fail $? "Could not set up authentication environment."
setup_cloud_services || fail $? "Could not setup cloud platform SDKs."
setup_database || fail $? "Could not set up database environments."
setup_nodedev || fail $? "Could not setup NODE.JS environemnt."
setup_pythondev || fail $? "Could not set up Python development environment."



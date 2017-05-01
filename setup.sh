#!/bin/sh

# Setup script (i.e. provisioning environment) for my development kit on Mac.
# Includes:
# - Homebrew, Node, and PIP (Python) package managers
# - Kubernetes and Docker (via Minikube and Docker Machine, using Xhyve)
# - Cloud SDKs and utilities for AWS and Google Cloud
# - Development utilities in Node.js and Python (2); also Python 3 base
# - Local database services & utilites for PostgreSQL, MySQL, and MongoDB
# - SSH keys if missing
# - Some BASH completion kit

set -e

export PATH="/usr/local/bin:${PATH}"
export DIR_COMPLETION=${HOME}/.bash_completion.d
export DIR_ENVIRON=${HOME}/.env.d
export FORCEFUL="${FORCEFUL:-0}"

[ "${DEBUG:-0}" -eq 1 ] && set -x

mkdir -p ${DIR_COMPLETION} ${DIR_ENVIRON}

requires(){ # simple wrapper to check presence of executables.
  which $@ >/dev/null
}

forceful() {
  [ "${FORCEFUL:-0}" -eq 1 ] && echo "$@"
}

color(){
  for i; do
    case "$i" in
      default) printf "\e[0m\e[39m";;
      green) printf "\e[32m";;
      red) printf "\e[31m";;
      yellow) printf "\e[33m";;
      end) printf "\e[0m\n";;
      *) printf "%s " "$i";
    esac
  done
}

status(){
  state=$1; shift 1;
  case "$state" in
    OK) color green "$@" end;;
    ERROR) color red "$@" end;;
    WARN) color yellow "$@" end;;
    INFO) color default "$@" end;;
  esac
}


fail(){
  err=$1; shift 1;
  status ERROR "$@" >&2
  exit $err
}

warn () {
  status ERROR "$@" >&2
}

info () {
  status INFO "$@" >&2
}

good () {
  status OK "$@" >&2
}

sudo -v || fail 1 "Cannot prepare system without sudo."


setup_homebrew () {
  requires xcodebuild || return $?
  requires sudo || return $?

  sudo xcodebuild -checkFirstLaunchStatus
  [ $? -eq 69 ] || sudo xcodebuild -license

  sudo xcode-select --install

  requires brew && return 0  # already installed

  info "Installing Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

}


setup_containerkit (){
  requires brew || return $?
  sudo mkdir -p /etc/{kubernetes,docker}

  # If they're already installed, clear exisitng links.
  brew unlink docker-machine docker-machine-completion

  # On a fresh installation these have to go first...
  brew install `forceful --overwrite` docker docker-machine
  brew link `forceful --overwrite` docker docker-machine

  brew install `forceful --overwrite` \
    docker-completion \
    docker-compose docker-compose-completion \
    xhyve docker-machine-driver-xhyve \
    docker-machine-nfs docker-clean


  brew install `forceful --overwrite` kubernetes-cli compose2kube
  brew install Caskroom/cask/minikube

  # The xhyve binary is missing from path?
  hash -r && requires xhyve || fail 1 "Could not locate xhyve."
  xhyve_path="$(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve"

  sudo chown root:wheel ${xhyve_path}
  sudo chmod u+s ${xhyve_path}


  # Start virtual machines if not present.
  docker-machine status docker-default | grep -v Running && docker-machine create -d xhyve docker-default


  minikube config get vm-driver | grep 'could not be found' && minikube config set vm-driver xhyve
  minikube status | grep -v Running && minikube start --vm-driver xhyve


  echo 'eval $(docker-machine env docker-default)' > ${DIR_ENVIRON}/docker.env.sh
  echo 'eval $(minikube docker-env)' > ${DIR_ENVIRON}/minikube.env.sh

  minikube completion bash > ${DIR_COMPLETION}/minikube.completion.sh


  good "Completed Kubernetes and Docker setup."
}


setup_hashicorp (){
  requires brew || return $?
  brew unlink vagrant-completion
  brew install `forceful --overwrite` \
    Caskroom/cask/vagrant{,-manager} \
    vagrant-completion \
    terraform
  brew link vagrant-completion
  good "Completed setup of Vagrant and Terraform"
}

setup_nodedev () {
  requires brew || return $?
  brew install `forceful --overwrite` node phantomjs
  npm install --upgrade -g \
    growl \
    {babel,gulp,grunt}-cli \
    gyp \
    nyc istanbul \
    jshint eslint \
    mocha \
    node-sass \
    google-closure-compiler-js
  good "Completed setup of Node.JS development environment."
}


setup_python_base () {
  requires easy_install || $?
  sudo easy_install pip
  sudo pip install --upgrade --ignore-installed six python-dateutil
  good "Completed setup of Python base environment."
}

setup_pythondev () {
  requires brew || return $?
  requires pip || return $?
  brew install `forceful --overwrite` python3
  sudo -H pip install \
    virtualenv vex \
    coverage nose unittest2 \
    pep8 pyflakes flake8 pylint \
    Jinja2 Pillow \
    lesscpy
  good "Completed setup of Python development environment."
}

setup_cloud_services (){
  requires brew || return $?
  requires pip || return $?
  brew install `forceful --overwrite` \
    Caskroom/cask/google-cloud-sdk
  sudo -H pip install \
    google-api-python-client \
    awscli awslogs
  good "Completed setup of Cloud development environment."
}

setup_system_libs () {
  requires brew || return $?
  brew install `forceful --force --overwrite` \
    libffi libgit2 \
    openssl wget \
    jpeg
}

setup_database (){
  requires brew || return $?
  brew install `forceful --overwrite` \
    mysql mongodb postgresql \
    Caskroom/cask/mongohub \
    Caskroom/cask/mysqlworkbench \
    Caskroom/cask/robomongo \
    Caskroom/cask/mongodbpreferencepane

  mkdir -p ~/Library/LaunchAgents
  cp `brew --prefix mysql`/*mysql*.plist ~/Library/LaunchAgents/
  launchctl load -w ~/Library/LaunchAgents/*mysql*.plist
  good "Completed setup of Database development environment."
}


setup_userkit () {
  # User environment
  requires brew || return $?
  brew install `forceful --overwrite` \
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
  [ -d ~/.ssh ] || mkdir -m 0700 ~/.ssh
  [ -f ~/.ssh/id_rsa ] || ssh-keygen -f ~/.ssh/id_rsa -C "${USER}@`hostname`" -b 4096
}



generate_bash_config () {
cat <<CONFIG
#!/bin/bash

temp=`mktemp /tmp/shellconfig.sh.XXXX`

# Load completion & environment from generated scripts.
find -L ${DIR_COMPLETION} -type f | xargs cat > \${temp};
find -L ${DIR_ENVIRON} -type f | xargs cat > \${temp};

# Load Homebrew-installed completion files automatically
which brew >/dev/null \
   && [ -f $(brew --prefix)/etc/bash_completion ] \
   && source $(brew --prefix)/etc/bash_completion

source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'

minikube status | grep -v Running && minikube start

source \${temp}
rm \${temp}

# end
CONFIG
}


setup_shellenviron () {
  requires brew || return $?
  brew install bash-completion
  generate_bash_config > ${HOME}/.bashrc_include
  grep -q 'bashrc_include' ~/.bash_profile || echo 'source ${HOME}/.bashrc_include' >> ~/.bash_profile
  good "Completed setup of Shell environment."
}

run_all_setup () {
  setup_shellenviron || fail $? "Could not set up shell environment."
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
}

MODE=${1:-all}

case $MODE in
  all) run_all_setup;;
  shell) setup_shellenviron;;
esac

[ "${DEBUG:-0}" -eq 1 ] && set +x
set +e

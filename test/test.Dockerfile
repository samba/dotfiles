FROM debian:stable

RUN apt-get -q update && apt-get install -y \
    make \
    rsync \
    sudo \
    openssh-client \
    git-core \
    python2.7
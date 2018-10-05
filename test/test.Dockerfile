FROM debian:stable
MAINTAINER Sam Briesemeister <sam.briesemeister@gmail.com>

RUN apt-get -q update && apt-get install -y \
    make \
    rsync \
    sudo \
    openssh-client \
    git-core \
    python2.7 python

RUN useradd -m -s /bin/bash tester && \
    usermod -aG sudo tester && \
    echo 'tester    ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir -p /home/tester && \
    chown tester: /home/tester


USER tester
ENV HOME /home/tester
WORKDIR /home/tester/code
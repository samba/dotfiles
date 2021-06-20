# Workspace Configuration

This is how I set up my working environment. 

Shortcuts: 
- [Bootstrapping](#bootstrap-installation)
- [Project home][5] [(direct link)][6]

### Credits Due

This repository is an amalgamation of my own fine-tuning, with some initial
inspiration drawn heavily from a few other developers. A few of them:

- [Mathias Bynens](https://github.com/mathiasbynens/dotfiles) 
- [Jess Frazelle](https://github.com/jessfraz/dotfiles)
- [Romain Lafourcade](https://gist.github.com/romainl/4b9f139d2a8694612b924322de1025ce)

### Bootstrap Installation

This should be copy-and-pastable.

**Prerequisites:**

- On Mac, install XCode
- On Debian, `apt-get install git-core make python python2.7`

```shell
git clone https://github.com/samba/dotfiles.git && cd dotfiles && make dotfiles
```

### Customization

The app installation phase relies on a collection of roles to identify groups 
of applications, based on the [package index](./util/packages.index.csv).

By default, the [Makefile](./Makefile) generates a list of roles, into `generated/roles.txt`, which is read to select apps for installation:
- developer
- user-cli
- security
- network
- libs
- python

Currently some other useful roles are defined:
- cloud
- kubernetes
- vms
- containers
- webdev
- mysql
- postgresql
- mongodb
- golang
- python-dev
- jsdev

To install these roles, ust modify the file `generated/roles.txt`, adding the
desired roles, and re-run `make apps`.

[5]: http://samba.github.com/dotfiles
[6]: ./docs/index.md

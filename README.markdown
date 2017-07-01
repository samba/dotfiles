# Workspace Configuration

This is how I set up my working environment.

# Philosophy

In my work, I frequently get to "drop in" to other sysadmin's environments, 
typically without singificantly customizing them. Thus I prefer to maintain my
familiarity with tools that are ubiquitous, typically already installed in core
distributions of Linux. I therefore unabashedly use `bash`, and `vim` with vigor. 
My own workspace affords a few more customizations, but I build my primary 
workflow around the tools I'll most often have at my disposal.

Pragmatic, though I do tolerate certain aspects of Apple's reliance on BSD even
when GNU is readily available. 

## Quickstart:

1. Install Xcode from App Store. Open it and accept the license.
2. Setup an SSH key
3. Clone this repository from GitHub
4. Perform installation

### Setup an SSH Key

```shell
ssh-keygen -C "${USER}@${HOSTNAME}"
cat ${HOME}/.ssh/id_rsa.pub
```

Then register this key on your GitHub profile ([SSH Keys][10]).

### Clone the repository

```shell
git clone git@github.com:samba/Workspace.git ./Workspace
```

### Install

Once Xcode is installed, this should just work ;)

```shell
sh setup.sh all
```

Currently Xcode license acceptance (and possibly other details) may require this to be run a few times, with manual handling of error results, if any come up. Sorry... rough edge. Still working on it ;)


## Additional Tools

- [Visual Studio Code][1]
- [GitHub for Mac][2]
- [Google Chrome][3]
- [Dash][4] Documentation Browser


## Software installed by this automation.

- Docker
- Minikube & Kubernetes CLI
- VirtualBox
- iTerm 
- PostgreSQL


## From AppStore

- Postico
- Slack
- Evernote
- Skitch
- Pocket
- Kindle
- Pixelmator
- Caffeine
- Xcode
- The Unarchiver
- Cinch

[1]: https://code.visualstudio.com/download
[2]: https://desktop.github.com/
[3]: https://www.google.com/chrome/browser/desktop/
[4]: https://kapeli.com/dash
[10]: https://github.com/settings/keys
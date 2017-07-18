# Workspace Configuration

This is how I set up my working environment. 
(Eventually I'll rename this back to "dotfiles"... undoing years of nonsense.)

### Credits Due

[Mathias Bynens](https://github.com/mathiasbynens/dotfiles) provides a great
example of a very simple model for handling these details. I've borrowed a few
ideas from Mathias' work, so be sure to take a look at his too.

## Set up the Dotfiles

```shell
sh setup.sh dotfiles ${HOME}
```

## Install Software

Likely this will require you to have Xcode installed, on a Mac.
You probably want only one of these variants:

```shell
sh setup.sh apps ${HOME} -o all  # does everything
sh setup.sh apps ${HOME} -o webdev
sh setup.sh apps ${HOME} -o containers
sh setup.sh apps ${HOME} -o cloud
sh setup.sh apps ${HOME} -o database
sh setup.sh apps ${HOME} -o golang
sh setup.sh apps ${HOME} -o python
sh setup.sh apps ${HOME} -o nodejs
```

## Setting Mac Defaults

```shell
sh macos/setup_mac_prefs.shell
```



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
- Caffeine
- (and lots of others...)


## From AppStore

Additional tools I find useful...

- Xcode
- Postico
- Slack
- Evernote
- Skitch
- Pocket
- Kindle
- Pixelmator
- The Unarchiver
- Cinch

[1]: https://code.visualstudio.com/download
[2]: https://desktop.github.com/
[3]: https://www.google.com/chrome/browser/desktop/
[4]: https://kapeli.com/dash
[10]: https://github.com/settings/keys
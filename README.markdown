# Workspace Configuration

This is how I set up my working environment. 
(Eventually I'll rename this back to "dotfiles"... undoing years of nonsense.)


### Credits Due

This repository is an amalgamation of my own fine-tuning, with some initial
inspiration drawn heavily from a few other developers. A few of them:

- [Mathias Bynens](https://github.com/mathiasbynens/dotfiles) 
- [Jess Frazelle](https://github.com/jessfraz/dotfiles)


## Installation

Probably you want one of these two modes:

```shell
make dotfiles  # installs just the dotfiles
make apps      # installs just the apps
```

For more options, try `make help`.

*Note*: a variety of macOS settings are automatically tuned during the `apps` phase. 
This process will terminate any running Chrome, Safari, and various other apps, due to actively changing settings. Unless the preferences file gets changed, this should only happen once.

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





## More Apps from the AppStore

Additional tools I find useful...

- Xcode  (*Note* this is probably required _first_ before this `Makefile` will work.)
- Postico
- Slack
- Evernote
- Skitch
- Pocket
- Kindle
- Pixelmator
- The Unarchiver
- Emphetamine
- Cinch
- Trello
- MindNode 5
- LastPass



[1]: https://code.visualstudio.com/download
[2]: https://desktop.github.com/
[3]: https://www.google.com/chrome/browser/desktop/
[4]: https://kapeli.com/dash
[10]: https://github.com/settings/keys

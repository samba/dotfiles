DATE := $(shell date +%Y-%m-%d-%H:%M:%S)
DOTFILES_DIR := $(shell pwd)
MY_BASHFILES := $(shell find bash/ -type f)
MY_VIMRCFILES := $(shell find vim/rc.d/ -type f)
MY_SCREENFILES = screenrc
MY_PYTHONFILES = pythonrc.py

DEST_FILES = ~/.bashrc ~/.bash_aliases ~/.bash_logout \
	~/.gnome2/nautilus-scripts ~/.screenrc ~/.vimrc ~/.pythonrc.py
BACKUP_OUTFILE := dotfiles-backup-$(shell date +%Y%m%d-%H%M%S).tar.gz


.PHONY: revisions-bash revisions-vim install clean

clean:
	-rm dotfiles-backup*.tar.gz


$(DEST_FILES):
	test -d "$@" || mkdir -p "$$(dirname "$@")"
	test -f "$@" || touch "$@"

list-active:
	ls -alh $(DEST_FILES)

backup-active: $(BACKUP_OUTFILE)

$(BACKUP_OUTFILE): $(DEST_FILES)
	tar -czf $@ $^

revisions-bash: $(MY_BASHFILES)
	$(shell echo $$EDITOR) $^

revisions-vim: vim/vimrc vim/vimrc-minimal $(MY_VIMRCFILES)
	$(shell echo $$EDITOR) $^


install: $(DEST_FILES) backup-active 
	test -d ~/.gnome2 && $(MAKE) install-nautilus-scripts || exit 0
	$(MAKE) install-bash
	$(MAKE) install-vim
	$(MAKE) install-screen
	$(MAKE) install-python

install-nautilus-scripts: ~/.gnome2/nautilus-scripts
	ln -sf $(DOTFILES_DIR)/nautilus-scripts/* $</

install-bash: $(MY_BASHFILES)
	ln -sf $(DOTFILES_DIR)/bash/bashrc.sh ~/.bashrc
	ln -sf $(DOTFILES_DIR)/bash/aliases ~/.bash_aliases
	ln -sf $(DOTFILES_DIR)/bash/logout.sh ~/.bash_logout

install-vim: $(MY_VIMRCFILES)  $(DOTFILES_DIR)/vim/vimrc
	ln -sf $(DOTFILES_DIR)/vim/vimrc ~/.vimrc
	ln -nsf $(DOTFILES_DIR)/vim ~/.vim

install-screen: $(MY_SCREENFILES) 
	ln -sf $(DOTFILES_DIR)/screenrc ~/.screenrc

install-python: $(MY_PYTHONFILES)
	ln -sf $(DOTFILES_DIR)/pythonrc.py ~/.pythonrc.py

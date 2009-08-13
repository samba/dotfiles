DATE := $(shell date +%Y-%m-%d-%H:%M:%S)
BASHFILES := $(shell find bash/ -type f)
VIMRCFILES := $(shell find vim/rc.d/ -type f)

.PHONY: bash-revisions vim-revisions install


bash-revisions: $(BASHFILES)
	$(shell echo $$EDITOR) $^

vim-revisions: vim/vimrc vim/vimrc-minimal $(VIMRCFILES)
	$(shell echo $$EDITOR) $^


install: install-bash install-vim install-screen install-python


install-bash: ~/.bashrc 
	-mv $< $<-$(DATE)
	ln -s ~/.dotfiles/bash/bashrc.sh $< 
	-mv ~/.bash_aliases ~/.bash_aliases-$(DATE)
	ln -s ~/.dotfiles/bash/aliases ~/.bash_aliases
	-mv ~/.bash_logout ~/.bash_logout-$(DATE)
	ln -s ~/.dotfiles/bash/logout.sh ~/.bash_logout

install-vim: ~/.vimrc 
	-mv $< $<-$(DATE)
	ln -s ~/.dotfiles/vim/vimrc $<
	-mv ~/.vim ~/.vim-$(DATE)
	ln -s ~/.dotfiles/vim ~/.vim

install-screen: ~/.screenrc
	-mv $< $<-$(DATE)
	ln -s ~/.dotfiles/screenrc $<


install-python: ~/.pythonrc.py
	-mv $< $<-$(DATE)
	ln -s ~/.dotfiles/pythonrc.py $<

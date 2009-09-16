DATE := $(shell date +%Y-%m-%d-%H:%M:%S)
BASHFILES := $(shell find bash/ -type f)
VIMRCFILES := $(shell find vim/rc.d/ -type f)
DOTFILES_DIR := $(shell pwd)


.PHONY: bash-revisions vim-revisions install


bash-revisions: $(BASHFILES)
	$(shell echo $$EDITOR) $^

vim-revisions: vim/vimrc vim/vimrc-minimal $(VIMRCFILES)
	$(shell echo $$EDITOR) $^


install: install-bash install-vim install-screen install-python


install-bash: ~/.bashrc 
	-mv $< $<-$(DATE)
	ln -s $(DOTFILES_DIR)/bash/bashrc.sh $< 
	-mv ~/.bash_aliases ~/.bash_aliases-$(DATE)
	ln -s $(DOTFILES_DIR)/bash/aliases ~/.bash_aliases
	-mv ~/.bash_logout ~/.bash_logout-$(DATE)
	ln -s $(DOTFILES_DIR)/bash/logout.sh ~/.bash_logout

install-vim: ~/.vimrc 
	-mv $< $<-$(DATE)
	ln -s $(DOTFILES_DIR)/vim/vimrc $<
	-mv ~/.vim ~/.vim-$(DATE)
	ln -s $(DOTFILES_DIR)/vim ~/.vim

install-screen: ~/.screenrc
	-mv $< $<-$(DATE)
	ln -s $(DOTFILES_DIR)/screenrc $<


install-python: ~/.pythonrc.py
	-mv $< $<-$(DATE)
	ln -s $(DOTFILES_DIR)/pythonrc.py $<

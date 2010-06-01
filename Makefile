
DATE := $(shell date +%Y%m%d%H%M%S)
DOTFILES_DIR := $(shell pwd)
BASH_FILES := $(shell find bash/ -type f)
VIM_FILES := $(shell find vim/rc.d/ -type f)

# Further dotfiles. If filename-HOSTNAME exists it takes precedence over default.
SINGLE_FILES = gitconfig screenrc dir_colors


# will be backed up
DEST_FILES := ~/.bashrc ~/.bash_aliases ~/.bash_logout \
						 ~/.vimrc ~/.gvimrc \
						 $(patsubst %,~/.%,$(SINGLE_FILES))


# This is significant only during initial deployment (afterwards the backup consists of just symlinks)
BACKUP_OUTFILE := backup-dotfiles-$(DATE).tar.gz


.PHONY: install clean edit-bash edit-vim edit-single


list-active:
	ls -alh $(DEST_FILES)

$(DEST_FILES):
	test -d "$@" || mkdir -p "$$(dirname "$@")"
	test -f "$@" || touch "$@"

backup-active: $(BACKUP_OUTFILE)

$(BACKUP_OUTFILE): $(DEST_FILES)
	tar -czf $@ $^ ~/.vim

edit-bash: $(BASH_FILES)
	$(shell echo $$EDITOR) $^

edit-vim: vim/vimrc vim/vimrc-minimal $(VIM_FILES)
	$(shell echo $$EDITOR) $^

edit-single: $(SINGLE_FILES)
	$(shell echo $$EDITOR) $^


install: $(DEST_FILES) backup-active
	$(MAKE) install-bash
	$(MAKE) install-vim
	$(MAKE) install-single

install-bash: $(BASH_FILES)
	ln -sf $(DOTFILES_DIR)/bash/bashrc.sh ~/.bashrc
	ln -sf $(DOTFILES_DIR)/bash/aliases.sh ~/.bash_aliases
	ln -sf $(DOTFILES_DIR)/bash/logout.sh ~/.bash_logout


# Cannot just remove ~/.vim if it's a dir because we only made a backup in `install' target
install-vim: $(VIM_FILES) $(DOTFILES_DIR)/vim/vimrc $(DOTFILES_DIR)/vim/gvimrc
	ln -sf $(DOTFILES_DIR)/vim/vimrc ~/.vimrc
	ln -sf $(DOTFILES_DIR)/vim/gvimrc ~/.gvimrc
	if [ -L ~/.vim ];then unlink ~/.vim; fi
	@if [ -d ~/.vim ]; then \
		mv ~/.vim ~/.vim-backup ; echo "##### NOTE: Existing ~/.vim copied to ~/.vim-backup #####"; \
	fi
	ln -nsf $(DOTFILES_DIR)/vim ~/.vim
	test -d ~/.vim/backup || mkdir --mode=0750 ~/.vim/backup
	test -d ~/.vim/swap || mkdir --mode=0750 ~/.vim/swap


install-single: $(SINGLE_FILES)
	for i in $^; do \
		if test -f $(DOTFILES_DIR)/$$i-$$HOSTNAME ; \
		then ln -sf $(DOTFILES_DIR)/$$i-$$HOSTNAME ~/.$$i ; \
		else ln -sf $(DOTFILES_DIR)/$$i ~/.$$i ; \
		fi \
	done


clean:
	-rm backup-dotfiles-*.tar.gz


# vim:noexpandtab

.PHONY: dotfiles apps install prefs

SHELL=/bin/bash
DATE?=$(shell date +%Y-%m-%d_%H%M)
DOCKER_TEST_IMAGE?=dotfiles_test:local
CACHE?=$(HOME)/.cache
USER?=$(shell whoami)
HOSTNAME?=$(shell hostname)
SYSTEM?=$(shell uname -s)
SSH_CONFIG?=$(HOME)/.ssh/config
SSHKEY_PASSWORD?=NOVALUE
KEEP_CACHE?=FALSE
PACKAGE_HANDLER?=$(shell bash util/systempackage.sh)
TEMP_TEST_DIR?=$(CURDIR)/.tmp/test

ifeq ($(SYSTEM),Linux)
LINUX_DISTRO?=$(shell command lsb_release -is)
LINUX_RELEASE?=$(shell command lsb_release -cs)
else
LINUX_DISTRO=none
LINUX_RELEASE=none
endif



# SED_FLAG ?= $(shell test $$(echo "test" | sed -E 's@[a-z]@_@g') = "____" && echo "-E" || echo "-R")

help: # borrowed from https://github.com/jessfraz/dotfiles/blob/master/Makefile
	@grep -oE '^([a-zA-Z]\w+: .* ##.*)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

apps: @install_packages  ## Install the applications

all: dotfiles apps prefs

install: dotfiles apps  ## Install everything (dotfiles + applications)

dotfiles:  ## Install the dotfiles
	$(MAKE) backup
	$(MAKE) @sync_dotfiles
	$(MAKE) @setup_config
	$(MAKE) sshkeys
	$(MAKE) @pythonconfig
	$(MAKE) @vimconfig
	$(MAKE) @shellsetup
	$(MAKE) @gosetup
	$(MAKE) @rustsetup
	@echo "OK all done!"

.PHONY: @sync_dotfiles
@sync_dotfiles: prereq
	rsync $(CURDIR)/dotfiles/ $(HOME)/ \
		--exclude ".git/" \
		--exclude ".osx" \
		--exclude ".DS_Store" \
		--exclude "*.md" \
		--exclude "*.txt" \
		-arvh --no-perms --no-links


$(SSH_CONFIG): dotfiles/.ssh/config.published Makefile
	mkdir -p $$(dirname $@)
	grep -q "config.published" $@ || \
		echo "Include ~/.ssh/config.published" >>$@

.PHONY: @setup_config
@setup_config: $(HOME)/.gitconfig $(SSH_CONFIG)
	mkdir -p $(HOME)/.ssh/keys $(HOME)/.ssh/sock
	chmod 0700 $(HOME)/.ssh


$(HOME)/.gitconfig: ./util/gitconfig.sh
	touch $@
	bash util/gitconfig.sh $@

.PHONY: @cache
@cache: $(CACHE)
$(CACHE):
	mkdir -p $@

$(TEMP_TEST_DIR):
	mkdir -p $@

.PHONY: clean
clean:
	rm -rf $(TEMP_TEST_DIR)

.PHONY: test
test: $(TEMP_TEST_DIR)  ## Populate a local temporary directory for testing.
	HOME=$< $(MAKE) @cache
	HOME=$< $(MAKE) @sync_dotfiles
	HOME=$< $(MAKE) @pythonconfig
	HOME=$< $(MAKE) @vimconfig
	@echo "# now:  HOME=$< bash -il " >&2

generated/:
	test -d $(@) || mkdir $(@)

.PHONY: roles
roles: generated/roles.txt  ## Generate roles for selecting packages
generated/roles.txt: util/packages.ini | generated/
	test -f $@ || \
		python3 util/packages.py -c $< -d > $@
	touch -r $< $@

.PHONY: packages
packages: generated/packages.sh  ## Generate package installer script
generated/packages.sh: generated/roles.txt util/packages.ini util/packages.py
	which python3
	@echo "> Package handler is: " $(PACKAGE_HANDLER) >&2
	python3 util/packages.py -c util/packages.ini $$(cat $<)> $@


.PHONY: prereq
prereq: generated/prereqs_installed.txt
generated/prereqs_installed.txt: debian/prereq.sh generated/
	date >> $@
ifeq ($(LINUX_DISTRO),Debian)
	command -v apt-get 2>/dev/null && bash debian/prereq.sh > $@
else ifeq ($(LINUX_DISTRO),Arch)
	command -v pacman 2>/dev/null && bash arch/prereq.sh >$@
endif


${HOME}/.empty:  # a placeholder
	date > $@

.PHONY: backup
backup: generated/backup.$(DATE).tar.gz  ## Backup archive of settings this might change.
generated/backup.$(DATE).tar.gz: generated/  ${HOME}/.empty
	# move any existing file to a discrete location.
	cd ${HOME} && tar -czf $(PWD)/$@ \
		--exclude=".git" \
		--exclude=".vim/view/*" --exclude=".vim/swap/*" \
		$$(ls -1d ./.bash* || exit 0) \
		$$(ls -1 ./.gitconfig* || exit 0) \
		$$(test -f ./.inputrc && echo ./.inputrc) \
		$$(test -f ./.psqlrc && echo ./.psqlrc) \
		$$(test -f ./.pythonrc.py && echo ./.pythonrc.py) \
		$$(test -f ./.screenrc && echo ./.screenrc) \
		$$(test -f ./.screenrc.macos && echo ./.screenrc.macos) \
		$$(test -f ./.config/htop/htoprc && echo ./.config/htop/htoprc) \
		$$(test -f ./.vimrc && echo ./.vimrc) \
		$$(test -d ./.vim && echo './.vim*') \
		$$(ls -1 ./.ssh/config* || exit 0) \
		$$(ls -1 ./.ssh/id_rsa* || exit 0) \
		$$(ls -1 ./.ssh/github_rsa* || exit 0) \
		${HOME}/.empty



.PHONY: import
import:  ## Copy changes from live system into this working directory.
	find ./dotfiles -type f -print | grep -v zshrc | sed 's@$(PWD)/@@; s@./dotfiles/@@;' | \
		while read df; do \
			diff -q "$${HOME}/$${df}" "./dotfiles/$${df}"; \
			test $$? -eq 1 || continue; \
			cp -v "$${HOME}/$${df}" "./dotfiles/$${df}"; \
		done
	# special cases...
	test -f  ~/.zshrc.$${USER} && cp -v ~/.zshrc.$${USER} ./dotfiles/.zshrc


clean-backup:
	rm -v generated/backup.*.tar.gz

.PHONY: prefs
prefs: $(CACHE)/mac_prefs_auto  ## Configure OS preferences
$(CACHE)/mac_prefs_auto: macos/setup_mac_prefs.shell
	mkdir -p $(@D)
	bash $^ apply reset
	touch -r $< $@

.PHONY: @install_respositories
@install_repositories:
ifeq ($(PACKAGE_HANDLER),apt-get)
	sudo bash ./debian/setup.sh repos
else ifeq ($(PACKAGE_HANDLER),pacman)
	sudo bash ./arch/setup.sh repos
endif

# Ensure that any newly installed Go binary is reachable
export PATH := $(PATH):/usr/local/go/bin/
export GOPATH := ${HOME}/Go/
export GO111MODULE := on


.PHONY: @install_packages
@install_packages: generated/packages.sh generated/roles.txt | @install_repositories
	echo "$(SYSTEM) $(LINUX_DISTRO)"
ifeq ($(SYSTEM),Darwin)
	bash macos/setup.sh install "$$(cat generated/roles.txt)"
endif
ifeq ($(SYSTEM) $(LINUX_DISTRO),Linux Debian)
	bash debian/setup.sh install "$$(cat generated/roles.txt)"
else ifeq ($(SYSTEM) $(LINUX_DISTRO),Linux Arch)
	bash arch/setup.sh install "$$(cat generated/roles.txt)"
endif
	bash -x $<  # install packages via generated/packages.sh
ifeq ($(SYSTEM),Darwin)
	bash macos/setup.sh configure
	# bash macos/setup_fonts.sh
endif
ifeq ($(SYSTEM) $(LINUX_DISTRO),Linux Debian)
	bash debian/setup.sh configure
else ifeq ($(SYSTEM) $(LINUX_DISTRO),Linux Arch)
	bash arch/setup.sh configure
endif


gitbackup: $(CACHE)/restore_git.sh ## Stash the unique settings of my git config
$(CACHE)/restore_git.sh: $(HOME)/.gitconfig  | $(CACHE)
	bash util/gitconfig.sh stash $<


gitrestore:    ## Restore the Git settings previously stashed
	bash -x util/gitconfig.sh restore $(HOME)/.gitconfig

# Preserve any key data that gets generated by this makefile. Avoid deleting it.
.PRECIOUS: $(HOME)/.ssh/%.password $(HOME)/.ssh/%_rsa

$(HOME)/.ssh/%.password:
	shuf -n 3 $$(find -L /usr/share/dict -type f | grep -e 'words' -e 'english' | head -n 1) | paste -sd '-' | tr -dc A-Za-z0-9- > $@

sshkeys: $(HOME)/.ssh/id_rsa $(HOME)/.ssh/github_rsa  ## Generate SSH keys automatically
$(HOME)/.ssh/%_rsa: $(HOME)/.ssh/%.password
	test -d $(HOME)/.ssh || mkdir -m 0700 $(HOME)/.ssh
ifeq ($(SSHKEY_PASSWORD),NOVALUE)
	test -f $@ || ssh-keygen -N "$$(cat $<)" -C "$(USER)@$(HOSTNAME)" -b 4096 -f $@
else
	test -f $@ || ssh-keygen -N "$(SSHKEY_PASSWORD)" -C "$(USER)@$(HOSTNAME)" -b 4096 -f $@
	grep -q "$(SSHKEY_PASSORD)" $< || echo "SSH key password differs from saved password file: $<" >&2
endif

.PHONY: @wipeout_cache
@wipeout_cache:
ifneq ($(KEEP_CACHE),FALSE)
	rm -rvf $(CACHE)
endif

.PHONY: @pythonconfig
@pythonconfig:  ## Set up Python programming environment
	which python3 && python3 -c "import site; print(site.getusersitepackages())" | \
		while read p; do \
			mkdir -p $$p; cp -v $(CURDIR)/generic/misc/usercustomize.py $$p/ ;\
		done

.PHONY: @gosetup
@gosetup:  ## Set up Go programming tools
	eval $$(grep "export GOPATH" ~/.bash_profile) && bash -x util/gosetup.sh install

.PHONY: @rustsetup
@rustsetup:  ## Set up rust programming tools
	bash util/rustsetup.sh


arch/packages.lst:
	sudo pacman -Qqe | grep -v "$$(sudo pacman -Qqm)" > $@

@pacman_restore: arch/packages.lst
	cat $< | sudo xargs pacman -S --needed --noconfirm


# Setup my common Vim extensions
.PHONY: @vimconfig
@vimconfig: $(CACHE)/vim_plugins_loaded  ## Set up vim config and plugins
$(CACHE)/vim_plugins_loaded: util/vimsetup.sh | $(CACHE)
	# This requires some bash-specific functionality.
	bash util/vimsetup.sh
	touch $@

.PHONY: @shellsetup
@shellsetup: @sync_dotfiles  ## Set up whell environment, especially tmux and zsh
	test -f ~/.tmux.status.conf || python3 generic/tmux_linegen.py -t orange > ~/.tmux.status.conf
	bash generic/setup_tmux.sh
	bash generic/setup_zsh.sh  # this is super noisy in debug...



$(CACHE)/test-docker-image: test/test.Dockerfile | $(CACHE)
	mkdir -p $(@D)
	docker build -t $(DOCKER_TEST_IMAGE) -f $< $(<D)
	touch -r $< $@

test-docker: $(CACHE)/test-docker-image
	docker run -it --rm -v "$(CURDIR):/home/tester/code" \
		$(DOCKER_TEST_IMAGE) /bin/bash test/run.sh /home/tester/code


run-docker: $(CACHE)/test-docker-image  ## Run this dotfiles project in a Docker Linux container.
	docker run -it --rm -v "$(CURDIR):/home/tester/code" \
		-e "SSHKEY_PASSWORD=testing" \
		$(DOCKER_TEST_IMAGE) /bin/bash -c 'make dotfiles && bash -il'

diff:  ## basically diff  -r ${HOME} ${repo} (for live dotfiles)
	@bash util/live_diff.sh print




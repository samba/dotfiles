.PHONY: dotfiles apps install

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

# SED_FLAG ?= $(shell test $$(echo "test" | sed -E 's@[a-z]@_@g') = "____" && echo "-E" || echo "-R")

help: # borrowed from https://github.com/jessfraz/dotfiles/blob/master/Makefile
	@grep -oE '^([a-zA-Z]\w+: .* ##.*)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

apps: @install_packages  ## Install the applications

install: dotfiles apps  ## Install everything (dotfiles + applications)

dotfiles:  ## Install the dotfiles
	$(MAKE) backup
	$(MAKE) @sync_dotfiles
	$(MAKE) @setup_config
	$(MAKE) sshkeys
	$(MAKE) @pythonconfig
	$(MAKE) @vimconfig
	@echo "OK all done!"

.PHONY: @sync_dotfiles
@sync_dotfiles:
	rsync $(CURDIR)/dotfiles/ $(HOME)/ \
        --exclude ".git/" \
        --exclude ".osx" \
        --exclude ".DS_Store" \
        --exclude "*.md" \
        --exclude "*.txt" \
        -arvh --no-perms --no-links

.PHONY: @setup_config
@setup_config: $(HOME)/.gitconfig
	grep -q "config.published" $(SSH_CONFIG) || \
		echo "Include ~/.ssh/config.published" >>$(SSH_CONFIG)
	mkdir -p $(HOME)/.ssh/keys $(HOME)/.ssh/sock
	chmod 0700 $(HOME)/.ssh


$(HOME)/.gitconfig: ./util/gitconfig.sh
	touch $@
	bash util/gitconfig.sh $@


$(CACHE):
	mkdir -p $@

generated/:
	mkdir $(@)

generated/roles.txt: generated/
	echo "developer user-cli security network libs python" > $@

generated/packages.sh: util/packages.index.csv util/packages.py generated/roles.txt
	which python
	@echo "> Package handler is: " $(PACKAGE_HANDLER) >&2
	python util/packages.py -i $< $(shell cat generated/roles.txt)> $@


.PHONY: backup
backup: generated/backup.$(DATE).tar.gz  ## Backup archive of settings this might change.
generated/backup.$(DATE).tar.gz: generated/
	# move any existing file to a discrete location.
	cd ${HOME} && tar -czf $(PWD)/$@ \
		--exclude=".git" \
		--exclude=".vim/view/*" --exclude=".vim/swap/*" \
		./.bash* \
		./.gitconfig* \
		$$(test -f ./.inputrc && echo ./.inputrc) \
		$$(test -f ./.psqlrc && echo ./.psqlrc) \
		$$(test -f ./.pythonrc.py && echo ./.pythonrc.py) \
		$$(test -f ./.screenrc && echo ./.screenrc) \
		$$(test -f ./.config/htop/htoprc && echo ./.config/htop/htoprc) \
		$$(test -f ./.vimrc && echo ./.vimrc) \
		./.vim* \
		./.ssh/config* \
		./.ssh/id_rsa*


clean-backup:
	rm -v generated/backup.*.tar.gz

$(CACHE)/mac_prefs_auto: macos/setup_mac_prefs.shell
	mkdir -p $(@D)
	bash $^
	touch -r $< $@

.PHONY: @install_packages	
@install_packages: generated/packages.sh 
ifeq ($(SYSTEM),Darwin)
	bash macos/setup.sh install
endif
	bash -x $<
ifeq ($(SYSTEM),Darwin)
	bash macos/setup.sh configure
	$(MAKE) $(CACHE)/mac_prefs_auto
endif



gitbackup: $(CACHE)/restore_git.sh ## Stash the unique settings of my git config
$(CACHE)/restore_git.sh: $(HOME)/.gitconfig  | $(CACHE)
	bash util/gitconfig.sh stash $<


gitrestore:    ## Restore the Git settings previously stashed
	bash -x util/gitconfig.sh restore $(HOME)/.gitconfig

$(HOME)/.ssh/id_rsa.password:
	dd if=/dev/urandom | LC_ALL=C tr -dc A-Za-z0-9 | head -c 48 > $@

sshkeys: $(HOME)/.ssh/id_rsa  ## Generate SSH keys automatically
$(HOME)/.ssh/id_rsa: $(HOME)/.ssh/id_rsa.password
	test -d $(HOME)/.ssh || mkdir -m 0700 $(HOME)/.ssh
ifeq ($(SSHKEY_PASSWORD),NOVALUE)
	test -f $@ || ssh-keygen -N "$$(cat $<)" -C "$(USER)@$(HOSTNAME)" -b 4096 -f $@
else
	test -f $@ || ssh-keygen -N "$(SSHKEY_PASSWORD)" -C "$(USER)@$(HOSTNAME)" -b 4096 -f $@
endif

.PHONY: @wipeout_cache
@wipeout_cache:
ifneq ($(KEEP_CACHE),FALSE)
	rm -rvf $(CACHE)
endif

# Install the Python usercustomize.py at the correct location. 
.PHONY: @pythonconfig
@pythonconfig:
	which python && python -c "import site; print site.getusersitepackages()" | \
		while read p; do \
			mkdir -p $$p; cp -v $(CURDIR)/generic/misc/usercustomize.py $$p/ ;\
		done

# Setup my common Vim extensions
.PHONY: @vimconfig
@vimconfig: $(CACHE)/vim_plugins_loaded
$(CACHE)/vim_plugins_loaded: util/vimsetup.sh
	# This requires some bash-specific functionality.
	bash util/vimsetup.sh
	touch $@


.cache/test-docker-image: test/test.Dockerfile
	mkdir -p $(@D)
	docker build -t $(DOCKER_TEST_IMAGE) -f $< $(<D)
	touch -r $< $@

test-docker: .cache/test-docker-image
	docker run -it --rm -v "$(CURDIR):/home/tester/code" \
		$(DOCKER_TEST_IMAGE) /bin/bash test/run.sh /home/tester/code


run-docker: .cache/test-docker-image  ## Run this dotfiles project in a Docker Linux container.
	docker run -it --rm -v "$(CURDIR):/home/tester/code" \
		-e "SSHKEY_PASSWORD=testing" \
		$(DOCKER_TEST_IMAGE) /bin/bash -c 'make dotfiles && bash -il'

diff:  ## basically diff  -r ${HOME} ${repo} (for live dotfiles)
	@bash util/live_diff.sh

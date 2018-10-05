.PHONY: dotfiles apps install

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

apps: @install_packages  ## just the applications

install: dotfiles apps  ## everything

dotfiles:  ## just the dotfiles
	$(MAKE) gitbackup
	$(MAKE) @sync_dotfiles
	$(MAKE) gitrestore
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
@setup_config:
	grep -q "config.published" $(SSH_CONFIG) || \
		echo "Include ~/.ssh/config.published" >>$(SSH_CONFIG)
	mkdir -p $(HOME)/.ssh/keys $(HOME)/.ssh/sock
	chmod 0700 $(HOME)/.ssh


$(CACHE):
	mkdir -p $@

$(HOME)/.gitconfig:
	echo "; empty .gitconfig" >$@

generated/:
	mkdir $(@)

generated/roles.txt: generated/
	echo "developer user-cli security network libs python" > $@

generated/packages.sh: util/packages.index.csv util/packages.py generated/roles.txt
	which python
	@echo "> Package handler is: " $(PACKAGE_HANDLER) >&2
	python util/packages.py -i $< $(shell cat generated/roles.txt)> $@

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


# Stash the unique settings of my git config
gitbackup: $(CACHE)/restore_git.sh
$(CACHE)/restore_git.sh: $(HOME)/.gitconfig  | $(CACHE)
	bash util/gitconfig.sh stash $<

# Restore the Git settings previously stashed
gitrestore:
	bash -x util/gitconfig.sh restore $(HOME)/.gitconfig


sshkeys: $(HOME)/.ssh/id_rsa
$(HOME)/.ssh/id_rsa:
	test -d $(HOME)/.ssh || mkdir -m 0700 $(HOME)/.ssh
ifeq ($(SSHKEY_PASSWORD),NOVALUE)
	ssh-keygen -C "$(USER)@$(HOSTNAME)" -b 4096 -f $@
else
	ssh-keygen -N "$(SSHKEY_PASSWORD)" -C "$(USER)@$(HOSTNAME)" -b 4096 -f $@
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
@vimconfig:
	# This requires some bash-specific functionality.
	bash util/vimsetup.sh


.cache/test-docker-image: test/test.Dockerfile
	mkdir -p $(@D)
	docker build -t $(DOCKER_TEST_IMAGE) -f $< $(<D)
	touch -r $< $@

test-docker: .cache/test-docker-image
	docker run -it --rm -v "$(CURDIR):/home/tester/code" \
		$(DOCKER_TEST_IMAGE) /bin/bash test/run.sh /home/tester/code


run-docker: .cache/test-docker-image
	docker run -it --rm -v "$(CURDIR):/home/tester/code" \
		$(DOCKER_TEST_IMAGE) /bin/bash -c 'make dotfiles && bash -il'
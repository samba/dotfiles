.PHONY: dotfiles apps install

DOCKER_TEST_IMAGE:=dotfiles_test:local
CACHE?=$(HOME)/.cache
USER?=$(shell whoami)
HOSTNAME?=$(shell hostname)
SYSTEM?=$(shell uname -s)
SSH_CONFIG?=$(HOME)/.ssh/config
SSHKEY_PASSWORD?=NOVALUE
KEEP_CACHE?=FALSE


apps:
	bash ./setup.sh apps $(HOME) -o all

install: dotfiles apps

dotfiles:
	$(MAKE) gitbackup
	$(MAKE) sync_dotfiles
	$(MAKE) gitrestore
	$(MAKE) setup_config
	$(MAKE) sshkeys
	$(MAKE) pythonconfig
	$(MAKE) vimconfig

sync_dotfiles:
	rsync $(CURDIR)/dotfiles/ $(HOME)/ \
        --exclude ".git/" \
        --exclude ".osx" \
        --exclude ".DS_Store" \
        --exclude "*.md" \
        --exclude "*.txt" \
        -arvh --no-perms --no-links

setup_config:
	grep -q "config.published" $(SSH_CONFIG) || \
		echo "Include ~/.ssh/config.published" >>$(SSH_CONFIG)
	mkdir -p $(HOME)/.ssh/keys $(HOME)/.ssh/sock
	chmod 0700 $(HOME)/.ssh


$(CACHE):
	mkdir -p $@

$(HOME)/.gitconfig:
	echo "; empty .gitconfig" >$@

packages.generated.sh: util/packages.index.csv util/packages.py
	which python
	echo "> Package handler is: " $(PACKAGE_HANDLER) >&2
	python util/packages.py -i $< > $@

	
install_packages: packages.generated.sh
	bash -x $<

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

wipeout_cache:
ifneq ($(KEEP_CACHE),FALSE)
	rm -rvf $(CACHE)
endif

# Install the Python usercustomize.py at the correct location. 
pythonconfig:
	python -c "import site; print site.getusersitepackages()" | \
		while read p; do \
			mkdir -p $$p; cp -v $(CURDIR)/generic/misc/usercustomize.py $$p/ ;\
		done

# Setup my common Vim extensions
vimconfig:
	# This requires some bash-specific functionality.
	bash util/vimsetup.sh


.cache/test-docker-image: test/test.Dockerfile
	mkdir -p $(@D)
	docker build -t $(DOCKER_TEST_IMAGE) -f $< $(<D)
	touch -r $< $@

test-docker: .cache/test-docker-image
	docker run -it --rm -v "$(CURDIR):/code" -w "/code" \
		$(DOCKER_TEST_IMAGE) /bin/bash test/run.sh /code
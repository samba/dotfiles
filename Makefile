.PHONY: dotfiles apps install

DOCKER_TEST_IMAGE:=dotfiles_test:local

dotfiles:
	bash ./setup.sh dotfiles ${HOME}


apps:
	bash ./setup.sh apps ${HOME} -o all

install: dotfiles apps

.cache/test-docker-image: test/test.Dockerfile
	mkdir -p $(@D)
	docker build -t $(DOCKER_TEST_IMAGE) -f $< $(<D)
	touch -r $< $@

test-docker: .cache/test-docker-image
	docker run -it --rm -v "$(CURDIR):/code" -w "/code" \
		dotfiles_test:local /bin/bash test/run.sh /code
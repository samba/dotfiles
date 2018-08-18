.PHONY: dotfiles apps install

dotfiles:
	bash ./setup.sh dotfiles ${HOME}


apps:
	bash ./setup.sh apps ${HOME} -o all

install: dotfiles apps



BASHFILES := $(shell find bash/ -type f)
VIMRCFILES := $(shell find vim/rc.d/ -type f)

.PHONY: bash-revisions vim-revisions


bash-revisions: $(BASHFILES)
	$(shell echo $$EDITOR) $^

vim-revisions: vim/vimrc vim/vimrc-minimal $(VIMRCFILES)
	$(shell echo $$EDITOR) $^


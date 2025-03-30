#!/usr/bin/env zsh
# Configuration loaded for interactive shells

export ZIM_CONFIG_FILE=~/.config/zsh/zimrc
export ZIM_HOME=~/.zim

export ZSH_CACHE_DIR=~/.cache/zsh
mkdir -p ${ZSH_CACHE_DIR}/completions

export MAIL=/var/mail/${USER}
export MAILCHECK=30


export HISTFILE=~/.zsh_history
export HISTSIZE=50000
export SAVEHIST=50000

export ZSH_TMUX_AUTOSTART=true

# my typical usage enjoys symlinks...
# setopt CHASE_LINKS

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_SAVE_NO_DUPS

setopt PUSHD_IGNORE_DUPS
setopt MAIL_WARN
setopt MAIL_WARNING
setopt CHECK_JOBS
setopt CHECK_RUNNING_JOBS

function _zimload () {

	mkdir -p $(dirname $ZIM_CONFIG_FILE)
	test -L ${ZIM_CONFIG_FILE} || ln -sf ~/.zimrc ${ZIM_CONFIG_FILE} || true

	# Download zimfw plugin manager if missing.
	if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then

		case $(command -v wget || command -v curl) in
			*curl) curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
				https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh ;;
			*wget) mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
				      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh ;;
		esac

	fi

	# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
	if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
		source ${ZIM_HOME}/zimfw.zsh init -q
	fi

	source ${ZIM_HOME}/init.zsh

}

# Set shell title based on user's typed command, then fall back to directory name
zstyle ':zim:termtitle' hooks 'preexec' 'precmd'
zstyle ':zim:termtitle:preexec' format '${${(A)=1}[1]}'
zstyle ':zim:termtitle:precmd'  format '%1~'


 _zimload

# load module edit-command-line from zshcontrib
autoload edit-command-line
autoload -U insert-files
autoload -U zargs
autoload -U zmv

# load default color shortcuts & prompts
autoload -U colors && colors
autoload -U promptinit && promptinit

# load widgets
zle -N edit-command-line

# ============================
# Key bindings

# let up- and down-arrow keys iterate through history
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Due to my history with bash, I'm accustomed to emacs-style keybindings...
bindkey -e  # sets emacs mode for ZLE  (see zshle(1))
# bindkey -v  # sets vi mode for ZLE  (see zshle(1))


# bindkey "^R" history-incremental-search-backward

# Edit the current command line in $EDITOR, via "ctrl-x ctrl-e" like bash
bindkey '\C-x\C-e' edit-command-line

# Beginning and end of line, like bash.
# bindkey '\C-a' beginning-of-line
# bindkey '\C-e' end-of-line


# == vi/vim-style keybindings too... just to confuse myself. ==

# this causes "Esc-V" to trigger editor
bindkey -M vicmd  v edit-command-line

# vim-like filename completion
bindkey "^Xf" insert-files




# =============================
# Prompt customization
# This must come after the theme loaded by Zim
# Effects:
#   - Keep main prompt PS1 as light as possible; one line, usually one character
#   - Add a few useful properties to the right-side prompt
#   - Move the default multi-line PS1 bits to the right-side prompt
#   - Touch up the color to fit with the theme I use in tmux
#   - Shorten the CWD notation to reflect 3 directory levels
# Additional color codes:
# https://unix.stackexchange.com/questions/124407/what-color-codes-can-i-use-in-my-bash-ps1-prompt 


PROMPT_COLOR=banana

case ${UID} in
    1) PROMPT_COLOR="009" ;; ## red for root
    *)  case $PROMPT_COLOR in
            green)  PROMPT_COLOR="034"   ;;
            amber)  PROMPT_COLOR="214"   ;;
            blue)   PROMPT_COLOR="019"   ;;
            banana) PROMPT_COLOR="227"   ;;
        esac ;;
esac



# Split the PS1 by newline
pslines=( ${(f)"${PS1//%~/%3~}"} )
linecount=${#pslines}

unset PS1
export PS1=${pslines[-1]//(green)/${PROMPT_COLOR}}
unset 'pslines[-1]'  # delete last one, i.e. pop from the array


PS1_KUBECTX="\$(command -v kubectl >/dev/null && kubectl config current-context 2>/dev/null)"

printf -v PS1 "%s %s %s \n%s" \
	"%F{${PROMPT_COLOR}}#%f" \
	"${${(j: :)pslines//\%~/%3~}//(cyan|green|magenta)/${PROMPT_COLOR}}" \
	"%F{${PROMPT_COLOR}}${PS1_KUBECTX}%f" \
    "$PS1" # the final line

printf -v RPROMPT "%s" \
	"%F{${PROMPT_COLOR}}< %T%f"


export RPROMPT
unset pslines linecount PROMPT_COLOR PS1_KUBECTX
# =======================


test -f ~/.zsh_aliases && source ~/.zsh_aliases
test -f ~/.zsh_functions && source ~/.zsh_functions
test -f ~/.zsh_localrc && source ~/.zsh_localrc

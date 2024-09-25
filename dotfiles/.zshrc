#!/usr/bin/env zsh


export ZIM_CONFIG_FILE=~/.config/zsh/zimrc
export ZIM_HOME=~/.zim


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

export ZSH_TMUX_AUTOSTART=true

setopt CHASE_LINKS

# Set shell title based on user's typed command, then fall back to directory name
zstyle ':zim:termtitle' hooks 'preexec' 'precmd'
zstyle ':zim:termtitle:preexec' format '${${(A)=1}[1]}'
zstyle ':zim:termtitle:precmd'  format '%1~'


 _zimload

# ============================
# Key bindings

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down


# =============================
# Prompt customization
# This must come after the theme loaded by Zim
# Effects:
#   - Keep main prompt PS1 as light as possible; one line, usually one character
#   - Add a few useful properties to the right-side prompt
#   - Move the default multi-line PS1 bits to the right-side prompt
#   - Touch up the color to fit with the theme I use in tmux
#   - Shorten the CWD notation to reflect 3 directory levels

PROMPT_COLOR="214"  # amber

# Split the PS1 by newline
pslines=( ${(f)"${PS1//%~/%3~}"} )
linecount=${#pslines}

unset PS1
export PS1=${pslines[-1]//(green)/${PROMPT_COLOR}}
unset 'pslines[-1]'  # delete last one, i.e. pop from the array

printf -v RPROMPT "%s %s %s %s %s" \
	"%F{${PROMPT_COLOR}}<%f" \
	"${${(j: :)pslines//\%~/%3~}//(cyan|green|magenta)/${PROMPT_COLOR}}" \
	"%F{${PROMPT_COLOR}}\$(command -v kubectl >/dev/null && kubectl config current-context 2>/dev/null)%f" \
	"%F{${PROMPT_COLOR}}%T%f"


export RPROMPT
unset pslines linecount PROMPT_COLOR
# =======================



test -f ~/.zsh_aliases && source ~/.zsh_aliases

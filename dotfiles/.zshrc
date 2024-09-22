#!/usr/bin/env zsh


export ZIM_CONFIG_FILE=~/.config/zsh/zimrc
export ZIM_HOME=~/.zim

# TODO: enable environment-specific options
# macos, archlinux, debian, brew

plugins=(
  vi-mode
  brew
  battery
  pyenv
)


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


#set -x
 _zimload
#set +x



#!/usr/bin/env bash

export PROMPT_REVERSE=1

# used later to indicate command error in prompt.
LAST_RETURN_CODE=0

# This is not expected to work in any other shells.
test "$(basename ${SHELL#-})" = "bash" || {
  echo "This prompt coloration script probably won't work right in your shell. ($SHELL)" >&2
  return 1
}

__prompt_color_hint () {
    # echo "TERM is ${TERM}" >&2
    case "$TERM" in
        xterm*)
            test "${COLORTERM:0:6}" = "gnome-" && \
                infocmp gnome-256color >/dev/null 2>&1 && \
                echo "gnome-256color"
            # also...
            infocmp xterm-256color >/dev/null 2>&1 && echo "xterm-256color"
            ;;
        *)
            test -z "$COLORTERM" || echo "$COLORTERM"
            echo "$TERM"
            ;;
    esac
}

__prompt_should_color () {
    test -z "$PS1" && return 1  # Don't color non-interactive.
    test -z "${1:-${COLORTERM}}" && return 1
    return 0
}

__send_screen_hardstatus () {
    if test -n "$STY"; then
        printf "\x1B_%s\x1B\\" "$@"  # screen hardstatus
        printf "\033k%s\033\\" "$@"
    else
        # This is normally interpreted as the shell title, in terminal emulators
        # like xterm, iTerm 2, etc
        printf "\033]0;%s\007" "$@"
    fi
}

__workingpath () {

    # Initially the title should be the current directory (shortened)
    local workingpath="$(pwd | sed -E "s@${HOME}@~@; s@([^/])[^/]*/@\\1/@g;")"

    # When operating over SSH, include hostname in title
    # NOTE: this assume this script is running remotely
    [ -z "$SSH_TTY"] || workingpath="${HOSTNAME%%.*}:${workingpath}"

    echo $workingpath
}


# This method exists solely to wrap a variety of importantly sequenced
# operations that should be executed as part of the $PROMPT_COMMAND
# ... rather than piling them in a giant string.
__generate_prompt_command () {
    LAST_RETURN_CODE=$?
    history -a >/dev/null;  # append history file.
    test -z "$VSCODE_CLI" && __send_screen_hardstatus "$(__workingpath)"
    
    # a null-title sequence for screen to interpret the live command
    test -n "$STY" && printf "\033k\033\134"  
}

__colorfilter () {
    if tput setaf 1 >/dev/null; then
        tput sgr0
        reset="$(tput sgr0)"
        bold="$(tput bold)"
        blue="$(tput setaf 33)"
        yellow="$(tput setaf 136)"
        green="$(tput setaf 64)"
        red="$(tput setaf 124)"
        orange="$(tput setaf 166)"
        cyan="$(tput setaf 37)"
        black="$(tput setaf 0)"
        purple="$(tput setaf 125)"
        white="$(tput setaf 15)"
        violet="$(tput setaf 61)"
    else
        reset='\e[0m'
        bold=''  # TODO
        blue='\e[01;34m'
        yellow='\e[01;33m'
        green='\e[01;32m'
        red='\e[01;31m'
        orange='\e[01;33m'
        cyan='\e[01;36m'
        black='\e[01;30m'
        purple='\e[01;35m'
        white='\e[01;37m'
        violet='\e[01;35m'
    fi

    format='%s'

    for i; do
        case "$i" in
            -e) format='\[%s\]' ;;
            -b) printf "$format" "$blue" ;;
            -g) printf "$format" "$green" ;;
            -r) printf "$format" "$red" ;;
            -y) printf "$format" "$yellow" ;;
            -c) printf "$format" "$cyan" ;;
            *) printf "${i}";;
        esac
    done

    printf "$format" "${reset}"
}


__color () {
    # A thin wrapper on __colormode
    read text
    case $1 in
        blue)  __colorfilter $2 -b  "$text" ;;
        red)  __colorfilter $2 -r "$text" ;;
        green) __colorfilter $2 -g "$text" ;;
        yellow) __colorfilter $2 -y "$text" ;;
        purple) __colorfilter $2 -p "$text" ;;
        cyan) __colorfilter $2 -c "$text" ;;
    esac
}


__git_prompt_status_template () {
    # This expects any color aspects to be embedded in the incoming template.

    local template
    local pad="${1}"
    read template

    which git >/dev/null 2>/dev/null || return 1

    # It's a valid git directory, and not ".git"
    test "`git rev-parse --is-inside-work-tree 2>/dev/null`" = "true" || return 1
    test "`git rev-parse --is-inside-git-dir 2>/dev/null`" = "false" || return 1

    git update-index --really-refresh -q &>/dev/null

    # seed values...
    branch=""
    staged=""
    stashed=""
    unstaged=""
    untracked=""

    # Produce the branch name first
    branch="${pad}$(git symbolic-ref --quiet --short HEAD || git rev-parse --short HEAD || echo "(unknown)")${pad}"
    
    # Staged changes
    git diff --quiet --ignore-submodules --cached || staged="${pad}+${pad}"    
 
    # Unstaged changes
    git diff-files --quiet --ignore-submodules -- || unstaged="${pad}!${pad}"
   
    # Untracked files
    test -z "`git ls-files --others --exclude-standard`" || untracked="${pad}?${pad}"
   
    # Stashed state
    git rev-parse --verify refs/stash &>/dev/null && stashed="${pad}\$${pad}"

    template="${template//\$br/${branch}}"
    template="${template//\$sg/${staged}}"
    template="${template//\$st/${stashed}}"
    template="${template//\$ug/${unstaged}}"
    template="${template//\$ut/${untracked}}"

    echo "${template}"

    return 0
}





# Prompt configuration wrapped in method with local vars to prevent littering shell namespace.
__generate_color_prompt () {

    # Initialize a generally compatible set of base colors & controls
    local bell='\[\a\]'
    local reset='\[\e[0m\]'
    local default='\[\e[39m\e[49m\]'
    local bold='\[\e[1m\]'  # TODO
    local blue='\[\e[01;34m\]'
    local yellow='\[\e[01;33m\]'
    local green='\[\e[01;32m\]'
    local red='\[\e[01;31m\]'
    local orange='\[\e[01;33m\]' # looks like yellow.
    local cyan='\[\e[01;36m\]'
    local black='\[\e[01;30m\]'
    local purple='\[\e[01;35m\]' 
    local white='\[\e[01;37m\]'
    local violet='\[\e[01;35m\]'
    
    local reverse='\e[7;m'
    local pad="\$(test 1 -eq \${PROMPT_REVERSE} && echo \" \" || echo \"\")"
    local rpad="\$(test 1 -eq \${PROMPT_REVERSE} && echo \"\" || echo \" \")"
    
    # displays bright background, with bold text
    # colors are reversed (automatically)
    local autoreverse="\[\e[\$((\${PROMPT_REVERSE} ? 7 : 0 ));\$((\${PROMPT_REVERSE} ? 1 : 0 ))m\]"
    
    # color is red if error, green otherwise
    # LAST_RETURN_CODE is updated via __generate_prompt_command (PROMPT_COMMAND)
    local error="\[\e[00;\$((\${LAST_RETURN_CODE} ? 31 : 32 ))m\]${autoreverse}"


    if tput setaf 1 >/dev/null; then
        tput sgr0 # reset now

        # The following start with a commonly compatible color code, followed
        # by a more specific color for terminals that support it. Normally
        # this should fail gracefully on older terminals.

        reset="\[$(tput sgr0)\]"
        bold="\[$(tput bold)\]"
        blue="\[$(tput setaf 4)$(tput setaf 33)\]"
        yellow="\[$(tput setaf 3)$(tput setaf 136)\]"
        green="\[$(tput setaf 2)$(tput setaf 64)\]"
        red="\[$(tput setaf 1)$(tput setaf 124)\]"
        orange="\[$(tput setaf 1)$(tput setaf 166)\]"
        cyan="\[$(tput setaf 6)$(tput setaf 37)\]"
        black="\[$(tput setaf 0)\]"
        purple="\[$(tput setaf 5)$(tput setaf 125)\]"
        white="\[$(tput setaf 7)$(tput setaf 15)\]"
        violet="\[$(tput setaf 5)$(tput setaf 61)\]"
        reverse="\[$(tput rev)\]"

        # TODO: allow named profiles (scripts) to override these.

    fi

    

    # command string to fetch context name
    local kubectx="which kubectl >/dev/null && kubectl config current-context 2>/dev/null"

    # command string to fetch context
    # (branch {untracked}{staged}{unstaged}{stashed})
    local gitfmt="${cyan}\$br${red}\$ut${orange}\$sg${yellow}\$ug${violet}\$st"
    printf -v gitstat "echo %q | __git_prompt_status_template \"${pad}\"" "$gitfmt"

    declare -a PROMPT_PARTS=(
        "${bell}${autoreverse}"
        "${cyan}${pad}\\\\t${pad}"                # timestamp
        "${error}${pad}\$?${pad}"                 # error status of last command
        "${default}${pad}\j${pad}"                # background jobs
        "${blue}${pad}\W${pad}"                   # current directory
        "\$(${gitstat})"                          # git context
        "${orange}${pad}\$(${kubectx})${pad}"     # kubernetes context
        "${reset}\n\$${reset}"                    # prompt ending
    )

    # The "%b" components must align to the PROMPT_PARTS elements.
    printf -v PS1 "%b%b${rpad}%b${rpad}%b${rpad}%b${rpad}%b${rpad}%b${rpad}%b%s" "${PROMPT_PARTS[@]}" "${reset} "

    export PS1="${PS1}"
    export PS2="${yellow}>${reset} "
    export PS3='> ' # PS3 doesn't get expanded like 1, 2 and 4
    export PS4="${blue}+${reset} "

    unset PROMPT_PARTS
    unset gitfmt
    unset gitstat
    unset kubectx
}

wtf () {
    printf "%s@%s:%s\n" \
        "$(echo $USER | __color yellow)" \
        "$(hostname -f | __color green)" \
        "$(pwd | sed "s@${HOME}@~@" | __color blue)" 
    
}


__basic_prompt () {
    printf -v PS1 '\\t \u@\h \W \j \$ ';
    export PS1;
    export PROMPT_COMMAND="";
    export GIT_PROMPT="";
}



export PROMPT_COMMAND="__generate_prompt_command"
export COLORTERM="$(__prompt_color_hint | head -n 1)"


if __prompt_should_color "${COLORTERM}"; then
    __generate_color_prompt
    
    # Fix terminal identification as it effects color features of `tput`
    case "${TERM}" in 
        screen|xterm) # common short terminal names
        case "${COLORTERM}" in
            truecolor|*-256color) # color is supported
                # enables `tput colors` == 256
                export TERM="${TERM}-256color"
            ;;
        esac
        test "truecolor" = "${COLORTERM}" && \
            screen -X eval "at # truecolor on"
        ;;
    esac
else
     __basic_prompt
fi


# Override manual title spec on first run.
# NB: keep this consistent with the shelltitle directive in .screenrc
test -n "$STY" && screen -X shelltitle '$ |shell'

unset __basic_prompt
# unset __generate_color_prompt
unset __prompt_should_color

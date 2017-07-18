#!/bin/sh

__prompt_color_hint () {
    case "$TERM" in
        xterm)
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
    test -z "$PS1" && return 1
    test -z "`__prompt_color_hint | head -n 1`" && return 1
    return 0
}

__generate_screen_state_control () {

    # Initially the title should be the current directory (shortened)
    local title="$(pwd | sed -E "s@${HOME}@~@; s@([^/])[^/]*/@\\1/@g;")"

    # When operating over SSH, include hostname in title
    # NOTE: this assume this script is running remotely
    [ -z "$SSH_TTY"] || title="${HOSTNAME%%.*}:${title}"

    # end of prompt
    printf '%bk%s%b%b' \\033 "${title:-shell}" \\033 \\0134
}


# This method exists solely to wrap a variety of importantly sequenced
# operations without the mess of punctuation of the prior approach of 
# injecting them into the $PROMPT_COMMAND 
__generate_prompt_command () {
    history -a;  # append history file.
    __generate_screen_state_control    # this must be last.
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

__git_prompt_status () {
    # This expects any color aspects to be embedded in the incoming template.

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
    branch="$(git symbolic-ref --quiet --short HEAD || git rev-parse --short HEAD || echo "(unknown)")"
    
    # Staged changes
    git diff --quiet --ignore-submodules --cached || staged="+"    
 
    # Unstaged changes
    git diff-files --quiet --ignore-submodules -- || unstaged="!"
   
    # Untracked files
    test -z "`git ls-files --others --exclude-standard`" || untracked="?"
   
    # Stashed state
    git rev-parse --verify refs/stash &>/dev/null && stashed="$"
    
    template="${template//Br/${branch}}"
    template="${template//Cs/$staged}"
    template="${template//Cu/$unstaged}"
    template="${template//St/$stashed}"
    template="${template//Fu/$untracked}"

    echo "$template"

    return 0
}


# Prompt configuration wrapped in method with local vars to prevent littering shell namespace.
__generate_color_prompt () {

    if tput setaf 1 >/dev/null; then
        tput sgr0
        reset="$(tput sgr0)"
        bold="$(tput bold)"
        blue="$(tput setaf 33)"
        yellow="$(tput setaf 190)"
        green="$(tput setaf 64)"
        red="$(tput setaf 124)"
        orange="$(tput setaf 166)"
        cyan="$(tput setaf 37)"
        black="$(tput setaf 0)"
        purple="$(tput setaf 135)"
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
        purple='\e[01;35m'  # more like fuscia?
        white='\e[01;37m'
        violet='\e[01;35m'
    fi


    local bell now user host workdir chroot shell jobs;

    printf -v bell '\[\a\]'
    
    # The timestamp
    printf -v now '\[%s\]\\t\[%s\]' "$cyan" "$reset"

    # Current username
    printf -v user '\[%s\]\\u\[%s\]' "$green" "$reset"

    # Current hostname
    printf -v host '\[%s\]\\h\[%s\]' "$yellow" "$reset"

    # Current working directory
    printf -v workdir '\[%s\]\\W\[%s\]' "$blue" "$reset"

    # Ending marker of the command prompt
    printf -v shell '\[%s\]\\$\[%s\]' "$green" "$reset"
    
    # Current background jobs
    printf -v jobs '\j' # no formatting

    # Append the return value of the last command to the prompt (red if error)
    # Note this uses old-school color formatting due to the deferred logic.
    printf -v errstat "\[\e[00;\$((\$? ? 31 : 32 ))m\]\$?\[\e[0m\]"

    printf -v gitfmt '\[%s\]Br\[%s\] \[%s\]Fu\[%s\]St\[%s\]Cs\[%s\]Cu\[%s\]' \
        "${cyan}" "${reset}" "${red}" "${yellow}" "${green}" "${purple}" "${reset}"

    GIT_PROMPT="\$(echo \"${gitfmt}\" | __git_prompt_status)"

    export PS1="${bell}${now} ${errstat} ${jobs} ${workdir} ${GIT_PROMPT} \\n${shell} "
    export PS2="$(__colorfilter -e -y ">") "
    export PS3='> ' # PS3 doesn't get expanded like 1, 2 and 4
    export PS4="$(__colorfilter -e -b "+")"

}

wtf () {
    printf "You are %s on %s in %s.\n" \
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
export COLORTERM="`__prompt_color_hint | head -n 1`"


if __prompt_should_color; then
    __generate_color_prompt
else
     __basic_prompt
fi


unset __basic_prompt
unset __generate_color_prompt

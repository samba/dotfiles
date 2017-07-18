#!/usr/bin/env bash
# The following utilities are only meaningful/available on MacOS...

alias plist="/usr/libexec/PlistBuddy"

# Lock screen
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"


# One of @janmoesen’s ProTip™s
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
	alias "$method"="lwp-request -m '$method'"
done
unset method

macutil () {

    case "$(uname -s)" in 
        Darwin) break ;;
        *) return 1 ;;
    esac

    case $1 in
        desktop)
            case $2 in
                show)
                    defaults write com.apple.finder CreateDesktop -bool true && killall Finder
                ;;
                hide)
                    defaults write com.apple.finder CreateDesktop -bool false && killall Finder 
                ;;
            esac
        ;;

        hiddenfiles)
            case $2 in
                show)
                    defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder
                ;;
                hide)
                    defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder 
                ;;
            esac
        ;;

        spotlight)
            case $2 in
                on) 
                    sudo mdutil -a -i on
                ;;
                off)
                    sudo mdutil -a -i off
                ;;
            esac
        ;;

    esac

}

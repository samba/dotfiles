#!/bin/sh

# These utilities are most useful in an audit capacity, when validating files
# outside of Git and attempt to resolve their state back to a point in a Git
# history.


show_help () {
    echo "Usage: $0 <mode> <terms>" >&2
    echo "Modes are:"
    echo -e "\t-n <filenames>  (report history of checksums for specific files)"
    echo -e "\t-c <commitid>   (report checksums for all files in a commit)"
    echo -e "\t-s <terms>      (search all commits for matching terms in files)"
}


gq () {


    mode=
    while getopts ':ncsh' Opt; do
        case $Opt in
            n)
                for filename; do
                    git log --format='%h' "${filename}" | while read commit; do
                        checksum=`git show ${commit}:${filename} | md5sum | cut -c 1-32`
                        printf '%s %s %s\n' "${checksum}" "${commit}" "${filename}"
                    done
                done
            ;;
            c)  
                for treeish; do
                    git ls-tree "${treeish}" | while read perms filetype object filename; do
                        checksum=`git cat-file ${filetype} ${object} | md5sum | cut -c 1-32`
                        printf '%s %s:%s\n' "${checksum}" "${treeish}" "${filename}"
                    done
                done
            ;;
            s) git grep "${@}" $(git rev-list --all) ;;
            h) show_help ; return 1 ;;
        esac
        break
    done

}
#!/bin/sh

# an easy routine (named in english) for detecting whether this is a live login.
is_login_shell () {
	[[ $0 =~ ^- ]] || [[ $- =~ i ]]
}

# TODO: remove this when we know it's no longer used
get_shell_config () {
	local ent=$1 scope=${2:auto}
  # echo "$ent: $scope" >&2
	ls -1 $MY_BASH/runtime-$scope/$ent 2>/dev/null
}

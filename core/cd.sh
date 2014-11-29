#!/bin/bash

###########################################################################
#                                                                         #
#  GitHelperTools. Set of tools to help mastering Git.                    #
#  Copyright (C) 2013  Erdem UNCUOGLU <erdem.uncuoglu at gmail.com>       #
#                                                                         #
#  This program is free software: you can redistribute it and/or modify   #
#  it under the terms of the GNU General Public License as published by   #
#  the Free Software Foundation, either version 3 of the License, or      #
#  (at your option) any later version.                                    #
#                                                                         #
#  This program is distributed in the hope that it will be useful,        #
#  WITHOUT ANY WARRANTY; without even the implied warranty of             #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
#  GNU General Public License for more details.                           #
#                                                                         #
#  You should have received a copy of the GNU General Public License      #
#  along with this program.  If not, see                                  #
#  <http://www.gnu.org/licenses/gpl-3.0.html>.                            #
#                                                                         #
###########################################################################


# Register module
_ght_register `basename "${BASH_SOURCE[0]}"`

# GLobal variables
declare -a __ght_cd_repos
__ght_cd_alias=""

# Init function
_ght_cd_init()
{
	local repo_base alias repo
	local repo_list=$__ght_self_dir/user
	__ght_cd_alias=
	unset __ght_cd_repos

	while read -r repo_file && [ -n "$repo_file" ]
	do
		_ght_log_core "cd :: `basename "$repo_file"`"
		while read -r repo_line
		do
			_ght_is_comment "$repo_line" && continue
			if [ `_ght_strindex "$repo_line" "="` -eq -1 ]; then
				case "$repo_line" in
					'~') repo_base="$HOME" ;;
					'~'/*) repo_base="$HOME/${repo_line#'~/'}" ;;
					*) repo_base="$repo_line" ;;
				esac
				continue
			else
				alias=`_ght_split "$repo_line" 0`
				repo=`_ght_split "$repo_line" 1`
				case "$repo" in
					'~') repo="$HOME" ;;
					'~'/*) repo="$HOME/${repo#'~/'}" ;;
					[^/]*) repo="$repo_base/$repo" ;;
				esac
				__ght_cd_alias=$__ght_cd_alias$alias" "
				__ght_cd_repos+=("$alias=$repo")
			fi
		done < "$repo_file"
	done <<<"$(find "$__ght_self_dir/user" -iname "*.repo" -print)"
}
_ght_cd_init

# Main function
_ght_cd_main()
{
	local oldIFS="$IFS"
	local fetch="false"
	local alias repo repo_line

	if [ $# -eq 0 ]; then
		pwd
		return $?
	fi

	case $1 in
	-r|--refresh)
		_ght_cd_init
		return 0
		;;
	-f|--fetch)
		fetch="true"
		shift
		;;
	esac

	for repo_line in "${__ght_cd_repos[@]}"
	do
		alias=`_ght_split "$repo_line" 0`
		repo=`_ght_split "$repo_line" 1`

		case "$1" in
		--list|-l|-L)
			IFS="■"
			if [ "$repo_line" == "${__ght_cd_repos[0]}" ]; then
				echo
				echo -e "    "`_ght_rpad Alias 12`"  Repository"
				echo -e "    "`_ght_repeat 12 -`"  "`_ght_repeat 24 -`
			fi
			[ "$1" = "-L" ] && repo=`dirname "$repo"`/`basename "$repo"` || repo=`basename "$repo"`
			echo -e "    "`_ght_rpad "$alias" 12`"  "$repo
			IFS="$oldIFS"
			continue
			;;
		$alias)
			cd "$repo" || return 1
			[ $fetch == "true" ] && git fetch --all
			return 0
			;;
		esac
	done
	return 0
}

# Completion function
_git_ght_cd()
{
	local cur
	local prev
	local public_args="-l --list -r --refresh -f --fetch"

	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD - 1]}

	[ -z "$__ght_cd_alias" ] && __ght_cd_alias="$public_args"

	if [ $prev == "-f" -o $prev == "--fetch" ]; then
		__gitcomp "$__ght_cd_alias"
	elif [ $prev == "cd" ]; then
		case "$cur" in
		-*)
			__gitcomp "$public_args"
			;;
		*)
			__gitcomp "$__ght_cd_alias"
			;;
		esac
	fi
	return 0
}

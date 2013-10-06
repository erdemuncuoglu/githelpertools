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
_ght_register "`basename ${BASH_SOURCE[0]}`"

# GLobal variables
declare -a __ght_cd_repos
declare __ght_cd_alias

# Init function
_ght_cd_init()
{
	local repo_file repo_line
	local repo_list=$__ght_self_dir/user
	__ght_cd_alias=
		
	for repo_file in $(ls $repo_list/*.repo 2> /dev/null)
	do
		echo "    Reading '`basename $repo_file`'"
		while read repo_line
		do
			[ "${repo_line:0:1}" == "#" ] && continue
			if [ `_ght_strindex "$repo_line" "="` -eq -1 ]; then
				case "$repo_line" in
					'~') repo_line="$HOME" ;;
					'~'/*) repo_line="$HOME/${repo_line#'~/'}" ;;
				esac
				[ -d $repo_line ] || break
			else
				__ght_cd_alias=$__ght_cd_alias`_ght_split $repo_line 0`" "
			fi
			__ght_cd_repos+=($repo_line)
		done < $repo_file
	done
}
_ght_cd_init

# Main function
_ght_cd_main()
{
	local oldIFS="$IFS"
	local fetch="false"
	local alias repo repo_base repo_line complete
	
	if [ $# -eq 0 ]; then
		pwd
		return 0
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
		if [ "${repo_line:0:1}" == "/" ]; then
			repo_base=$repo_line
			alias=
		else
			alias=`_ght_split $repo_line 0`
			repo=`_ght_split $repo_line 1`
		fi
		
		case "$1" in
		--complete)
			complete="$complete$alias "
			continue
			;;
		--list|-l)
			IFS="■"
			if [ -z "$alias" ]; then
				echo
				echo -e "Repo dir : "$repo_base
				echo -e "    "`_ght_rpad Alias 12`"  Repository"
				echo -e "    "`_ght_repeat 12 -`"  "`_ght_repeat 16 -`
			else
				echo -e "    "`_ght_rpad $alias 12`"  "$repo
			fi
			IFS="$oldIFS"
			continue
			;;
		$alias)
			cd "$repo_base/$repo" || return 1
			[ $fetch == "true" ] && git fetch --all
			return 0
			;;
		$repo_base)
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

	if [ "$prev" == "cd" ]; then

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

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


# Register module/plugin
_ght_register "`basename ${BASH_SOURCE[0]}`"

_ght_cd()
{
	local public_args="-l --list -r --reload"
	local priv_args="--complete --args"
	local repo_list=$self_dir/user
	local repo_base=""
	local oldIFS="$IFS"
	
	if [ $# -eq 0 ]; then
		pwd
		return 0
	fi
	
	for repo_file in $(ls $repo_list/*.repo 2> /dev/null)
	do
		#repo_file="$file"
		while read line
		do
			[ "${line:0:1}" == "#" ] && continue

			if [ -z $repo_base ]; then

				if [ "${line:0:1}" == "/" -o "${line:0:1}" == "~" ]; then
					repo_base="$line"

					if [ x"$1" == "x--list" -o x"$1" == "x-l" ]; then
						echo
						echo -e "Repo dir : "$repo_base
						echo -e "    Alias         Repository"
						echo -e "    ------------  ----------------"
					fi
				fi
				continue
			fi

			if [[ "$line" != *=* ]]; then
				continue
			fi

			key=`_ght_split $line 0`
			val=`_ght_split $line 1`
			if [ x"$1" == "x--list" -o x"$1" == "x-l" -o x"$1" == "x--complete" ]; then
				IFS="■"
				if [ x"$1" == "x--complete" ]; then
					echo -e "	$key	"
				else
					echo -e "    "`_ght_rpad $key 12`"  "$val
				fi
				IFS="$oldIFS"
			elif [ x"$1" == x"$key" ]; then
				cd $repo_base/$val || return 1
				git fetch --all
				return 0
			elif [ x"$1" == "x--backup" ]; then
				if [ ! -d $BACKUP_BASE/$val ]; then
					_ght_mkdir $BACKUP_BASE/$val
				fi
				cp -fv $repo_base/$val/.classpath $BACKUP_BASE/$val/
				return 0
			fi
		done < $repo_file
		repo_base=""
	done

	[ x"$1" != "x--list" -a x"$1" != "x-l" -a x"$1" != "x--backup" -a x"$1" != "x--complete" ] && cd "$1"
	return $?
}

_git_ght_cd()
{
	local cur
	local prev
	local params="-l --list"
	
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD - 1]}

	if [ "$prev" == "cd" ]; then

		case "$cur" in
		-*)
			__gitcomp "$params"
			;;
		*)
			__gitcomp "$(_ght_cd --complete)"
			;;
		esac
	fi
	return 0
}

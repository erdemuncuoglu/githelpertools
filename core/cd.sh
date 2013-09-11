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


__gitcd()
{
	if [ $# -eq 0 ]; then
		git fetch --all
		return 0
	fi
	
	#local BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	local repo_list=$self_dir/user
	local repo_base=""
	local oldIFS="$IFS"
	
	for repo_file in $(ls $repo_list/*.repo); do
		
		#repo_file="$file"
		while read line; do
			
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
			
			key=`__split $line 1`
			val=`__split $line 2`
			if [ x"$1" == "x--list" -o x"$1" == "x-l" ]; then
				IFS="■"
				echo -e "    "`__rpad $key 12`"  "$val
				IFS="$oldIFS"
			elif [ x"$1" == x"$key" ]; then
				cd $repo_base/$val || return 1
				git fetch --all
				return 0
			elif [ x"$1" == "x--backup" ]; then
				if [ ! -d $BACKUP_BASE/$val ]; then
					__mkdir $BACKUP_BASE/$val
				fi
				cp -fv $repo_base/$val/.classpath $BACKUP_BASE/$val/
				return 0
			fi
		done < $repo_file
		repo_base=""
	done
	
	[ x"$1" != "x--list" -a x"$1" != "x-l" -a x"$1" != "x--backup" ] && cd "$1"
	return $?
}

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

# Main function
_ght_tug_main()
{
	[ -n "$1" ] && branches=$1 || branches=$(__git_heads)
	[ -n "$2" ] && ref=$2 || ref=refs/remotes/$(_ght_getremote)/$(_ght_getconfig branch)

	remote=$(_ght_split $ref 2 "/")
	"$__ght_git_cmd" fetch $remote

	for branch in $branches
	do
		[ `_ght_strindex "$branch" refs/heads` -eq -1 ] && branch=refs/heads/$branch
		#git update-ref refs/heads/branch_name refs/remotes/origin/master
		ahead=$("$__ght_git_cmd" rev-list $ref..$branch | wc -l)
		behind=$("$__ght_git_cmd" rev-list $branch..$ref | wc -l)

		if [[ $ahead -gt 0 && $behind -gt 0 ]]; then
			echo "${branch##*/} and ${ref##*remotes/} are diverged."
		elif [[ $ahead -gt 0 ]]; then
			echo "${branch##*/} is ahead of ${ref##*remotes/} by ${ahead// } commit(s)."
		elif [[ $behind -gt 0 ]]; then
			git update-ref $branch $ref
		#else
			#echo "${branch##*/} and ${ref##*remotes/} are same."
		fi

		#echo "branch : "$branch
		#echo "ref    : "$ref
	done

	return 0
}

# Completion function
_git_ght_tug()
{
	[ $COMP_CWORD -eq 2 ] && __gitcomp_nl "$(__git_heads)"
	[ $COMP_CWORD -eq 3 ] && __gitcomp_nl "$(__git_refs | grep '/')"
	return 0
}

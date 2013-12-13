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
_ght_new_main()
{
	local track_ref
	local remote=$(_ght_getremote)
	
	[ -z "$remote" ] && return 1
	if [ -n "$1" ]; then
		if [ -z "$2" ]; then
			track_ref="$remote/`_ght_getconfig branch`"
		else
			track_ref="$2"
			if [ `_ght_strindex "$track_ref" "/"` -ge 0 ]; then
				remote=`_ght_split "$track_ref" 0 "/"`
			fi
		fi
		_ght_rungit fetch $remote && _ght_rungit checkout -b "$1" "$track_ref"
		return $?
	fi
	return 127
}

# Completion function
_git_ght_new()
{
	[ $COMP_CWORD -eq 2 ] && __gitcomp_nl "$(__git_heads)"
	[ $COMP_CWORD -eq 3 ] && __gitcomp_nl "$(__git_refs | grep '/')"
	return 0
}

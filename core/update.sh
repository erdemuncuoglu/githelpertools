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

# Main function
_ght_update_main()
{
	local branch
	
	[ -z $1 ] && branch=master || branch=$1
	_ght_checkversion --verbose $branch
	[ $? -ne 2 ] && return 1
	(
		cd $__ght_self_dir
		_ght_rungit fetch --all
		#TODO:2013-10-06:erdem:read remote from config  
		remote=origin
		[ -n $remote ] && git reset --hard $remote/$branch
	)
	if [ -x $__ght_self_dir/install.sh ]; then
		$__ght_self_dir/install.sh --update && exec bash -l
	fi
	return 0
}

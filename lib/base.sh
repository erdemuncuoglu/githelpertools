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



export __ght_git_cmd=`type -fp git`
if [ $? != 0 ]; then
	echo "Cannot find GIT..."
	return 2
fi

__ght_name="gitHelperTools"
__ght_version=$(cat "$__ght_self_dir/VERSION")

while IFS= read -d $'\n' -r lib_file && test -n "$lib_file"
do
	if [ "$lib_file" != "${BASH_SOURCE[0]}" ]; then
		source "$lib_file"
	fi
done <<<"$(find "$__ght_self_dir/lib/" -iname "*.sh" -print)"
unset lib_file

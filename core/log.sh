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
_ght_log_main()
{
	if [ -z "$1" ]; then
		_ght_rungit log --graph --full-history --all --color --pretty=format:'%Cred%h%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>' --date-order
		#_ght_rungit log --graph --full-history --all --color --pretty=format:'%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s' --date-order
		ec=$?
	else
		_ght_rungit log "$@"
	fi
}

# Completion function
_git_ght_log()
{
	_git_log
	return 0
}

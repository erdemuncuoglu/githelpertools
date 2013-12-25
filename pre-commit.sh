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


__ght_self_dir=`cd "$(git rev-parse --show-toplevel)" && pwd`
[ -f "$__ght_self_dir/lib/base.sh" ] && . "$__ght_self_dir/lib/base.sh" || exit 0
cd "$__ght_self_dir"

branch=`git rev-parse --abbrev-ref HEAD`
develbranch=`_ght_getconfig develbranch`
[ "$branch" != "$develbranch" ] && exit 0

status=`git status --porcelain`
[ -z "$status" ] && exit 0

file="$__ght_self_dir/VERSION"
ver=`cat $file`
if [ $? -gt 0 ]; then
	echo "Can't read VERSION file"
	exit 1
fi

stable=${ver%.*}
devel=${ver##*.}
devel=$((devel + 1))
newver=$stable.$devel

echo $newver > $file
git add -A $file
exit 0

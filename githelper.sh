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


__ght_git_cmd=`type -fp git`
if [ ! -x $git_cmd ]; then
	echo "Cannot find GIT..."
	return 2
fi

__ght_self_dir=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)`

[ -f $__ght_self_dir/lib/base.sh ] && . $__ght_self_dir/lib/base.sh || return 1

echo
for user_extention in $(ls $__ght_self_dir/plugins/*.sh 2> /dev/null)
do
	echo "Loading '`basename $user_extention`'"
	source $user_extention
done
unset user_extention

for core_extention in $(ls $__ght_self_dir/core/*.sh 2> /dev/null)
do
	echo "Loading '`basename $core_extention`'"
	source $core_extention
done
unset core_extention

#TODO:2013-10-06:erdem:log file name will be determined from config options
__ght_log_file=$__ght_self_dir/log/githelper.log
_ght_touch $__ght_log_file

echo
echo "$__ght_name v$__ght_version"
echo "Copyright (C) 2013  Erdem UNCUOGLU <erdem.uncuoglu at gmail.com>"
echo "This software is licensed under GPL version 3. See file COPYING for details."
_ght_checkversion --verbose
echo

git()
{
	local ec=127
	local run_cmd=_ght_$1_main

	if [ `type -t $run_cmd 2> /dev/null` == "function" ]; then
		shift
		$run_cmd "$@"
		ec=$?
	else
		_ght_rungit "$@"
		ec=$?
	fi		
	return $ec;

#TODO:2013-10-06:erdem:deprecated way of calling extensions. Convert sections to core extentions  
	case "$1" in
		update)
			[ -z $2 ] && branch=master || branch=$2
			_ght_checkversion --verbose $branch
			[ $? -ne 2 ] && return $ec
			(
				cd $__ght_self_dir
				_ght_rungit fetch --all
				remote=
				remotes=`git remote -v`
				oldIFS=$IFS
				IFS=$'\n'
				for line in $remotes
				do
					if [ "${line%%github.com*}" != "$line" -a "${line%%githelpertools*}" != "$line" ]; then
						remote=`echo $line | cut -f 1`
						break
					fi
				done
				[ -n $remote ] && git reset --hard $remote/$branch
			)
			if [ -x $__ght_self_dir/install.sh ]; then
				$__ght_self_dir/install.sh --update && exec bash -l
			fi
			;;
		cd)
			type -p _ght_cd &> /dev/null || return $ec
			shift
			_ght_cd "$@"
			ec=$?
			;;
		upd)
			type -p _ght_gitupd &> /dev/null || return $ec
			shift
			_ght_gitupd "$@"
			ec=$?
			;;
		new)
			shift
			if [ -n "$1" ]; then
				[ -z "$2" ] && base_branch="master" || base_branch="$2"
				_ght_rungit fetch origin
				_ght_rungit checkout -b "$1" "origin/$base_branch"
				ec=$?
			fi
			;;
		log)
			shift
			if [ -z "$1" ]; then
				_ght_rungit log --graph --full-history --all --color --pretty=format:'%Cred%h%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>' --date-order
				#_ght_rungit log --graph --full-history --all --color --pretty=format:'%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s' --date-order
				ec=$?
			else
				_ght_rungit log "$@"
			fi
			;;
		*)
			_ght_rungit "$@"
			;;
	esac
	return $ec;
}

_ght_rungit()
{
	$__ght_git_cmd "$@"
	ec=$?
#TODO:2013-10-06:edem:must implement a '_ght_log' function instead
	echo `date +"%Y-%m-%d %H:%M:%S"`" :: $ec :: $@" >> $__ght_log_file
	return $ec
}

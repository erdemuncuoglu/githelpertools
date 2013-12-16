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


export __ght_self_dir=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd`

[ -f "$__ght_self_dir/lib/base.sh" ] && . "$__ght_self_dir/lib/base.sh" || return 1

_ght_helper_conf()
{
	local conf_file
	while IFS= read -d $'\n' -r conf_file && test -n "$conf_file"
	do
		while read -r conf_line
		do
			[ "${conf_line:0:1}" == "#" ] && continue
			if [ `_ght_strindex "$conf_line" "="` -gt -1 ]; then
				conf_name=$(_ght_trim `_ght_split "$conf_line" 0`)
				conf_value=$(_ght_trim `_ght_split "$conf_line" 1`)
				if [ -n "$conf_value" ]; then
					"$__ght_git_cmd" config --global --unset-all ght.$conf_name
					"$__ght_git_cmd" config --global --add ght.$conf_name $conf_value
				fi
			fi
		done < "$conf_file"
		_ght_log_core `basename "$conf_file"`
	done <<<"$(find "$__ght_self_dir/conf" "$__ght_self_dir/user" -iname "*.conf" -print)"
}

_ght_helper_loadextention()
{
	local user_extension
	while IFS= read -d $'\n' -r user_extension && test -n "$user_extension"
	do
		_ght_log "Plugin : `basename "$user_extension"`"
		source "$user_extension"
	done <<<"$(find "$__ght_self_dir/plugins" -iname "*.sh" -print)"

	local core_extension
	while IFS= read -d $'\n' -r core_extension && test -n "$core_extension"
	do
		_ght_log_core `basename "$core_extension"`
		source "$core_extension"
	done <<<"$(find "$__ght_self_dir/core" -iname "*.sh" -print)"
}

_ght_register helper

_ght_helper_main()
{
	case "$1" in
	-r|--reload-conf)
		_ght_helper_conf
		;;
	esac
	return 0
}

_git_ght_helper()
{
	local cur
	local public_args="-r --reload-conf"

	cur=${COMP_WORDS[COMP_CWORD]}

	case "$cur" in
	-*)
		__gitcomp "$public_args"
		;;
	*)
		__gitcomp "$public_args"
		;;
	esac
	return 0
}


echo
echo "$__ght_name v$__ght_version"
echo "Copyright (C) 2013  Erdem UNCUOGLU <erdem.uncuoglu at gmail.com>"
echo "This software is licensed under GPL version 3. See file COPYING for details."

_ght_helper_conf

_ght_getconfig checkupdate && _ght_checkversion --verbose

_ght_helper_loadextention

echo

while IFS= read -d $'\n' -r func_name
do
	func_name=${func_name##d* }
	export -f $func_name
done <<<"$(declare -F | egrep -e " _ght_.*")"

git()
{
	local ec=127
	local run_cmd=_ght_$1_main
	local args="$*"

	if [ "`type -t $run_cmd 2> /dev/null`" == "function" ]; then
		shift
		$run_cmd "$@"
		ec=$?
		_ght_log $ec $args
	else
		_ght_rungit "$@"
		ec=$?
	fi
	return $ec;
}

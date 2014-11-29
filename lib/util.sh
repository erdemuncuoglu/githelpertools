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


# Inline funtion to run git commands
# Usage _ght_rungit <param> ...
_ght_rungit()
{
	"$__ght_git_cmd" "$@"
	ec=$?
	_ght_log $ec "$@"
	return $ec
}

# Logger functions
# Usage _ght_log <logstring>
# Usage _ght_log_user <logstring>
# Usage _ght_log_core <logstring>
# Usage _ght_log_ec <exitcode> <logstring>
_ght_log()
{
	local filename
	local rotate

	case `_ght_getconfig logrotate` in
		monthly)
			filename=`date +"%Y-%m"`-01.log;;
		weekly)
			filename=`date -d "$(( $(date +%u) - 1 )) days ago" +"%F"`.log;;
		daily)
			filename=`date +"%F"`.log;;
		*)
			filename=`_ght_getconfig logfile` || filename=githelper.log;;
	esac
	[[ "${filename:0:1}" != "/" && "${filename:0:1}" != "~" ]] && filename="$__ght_self_dir/log/$filename"
	_ght_touch "$filename"

	echo [`date +"%F %T"`] "$*" >> "$filename"
}

_ght_log_ec()
{
	local prefix

	if [ $1 -ge 0 ] 2> /dev/null; then
	prefix="$1 :: "
		shift
	fi
	_ght_log "$prefix$*"
}

_ght_log_user()
{
	_ght_log "User :: $*"
}

_ght_log_core()
{
	_ght_log "Core :: $*"
}

# Get value of a configuration option
# Usage _ght_config_get <option>
_ght_getconfig()
{
	local key=$1
	local value
	local ec

	if [ -n "$key" ]; then
		value=` "$__ght_git_cmd" config --global --get ght.$key 2> /dev/null`

		[ $? -ne 0 -o -x "$value" ] && value='error'
		if [ "$value" == "yes" ]; then
			ec=0
		elif [ "$value" == "no" ]; then
			ec=1
		else
			echo $value
		fi
	fi
	return $ec
}

# Get remote name
# Usage _ght_getremote
_ght_getremote()
{
	local remote=`_ght_getconfig remote`

	if [ -z "$remote" ]; then
		remote=`git remote -v | grep -i -e "github" | head -1 | cut -d $'\t' -f 1`
	fi

	[ -z "$remote" ] && return 1
	echo $remote
	return 0
}

# Returns argument at <index>
# Usage _ght_nthparam index args...
_ght_nthparam()
{
	local ind=$1
	shift
	echo ${@:$1:1}
	return 0
}

# Returns last in <args...>
# Usage _ght_lastparam args...
_ght_lastparam()
{
	local len=$#

	[ $len -eq 0 ] && return 1
	while [ $len -gt 1 ]
	do
		shift
	done
	echo $1
	return 0
}

# Enhanced version of command touch
# Try `touch --help' for more information.
# Usage _ght_touch <args...>
_ght_touch()
{
	local params="$@"
	local file=`_ght_lastparam "$@"`

	[ -e "$file" ] && return 1
	touch "$@" &> /dev/null && return 0
	mkdir -p "`dirname "$file"`"
	[ $? -eq 0 ] && touch "$@" || return 1
	return $?
}

# Compares two version strings
# Original source <http://stackoverflow.com/a/4025065>
# Usage _ght_vercomp version1 version2
_ght_vercomp()
{
	if [[ $1 == $2 ]]; then
		return 0
	fi
	local IFS=.
	local i
	local ver1=($1)
	local ver2=($2)
	# fill empty fields in ver1 with zeros
	for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
	do
		ver1[i]=0
	done
	for ((i=0; i<${#ver1[@]}; i++))
	do
		if [[ -z ${ver2[i]} ]]; then
			# fill empty fields in ver2 with zeros
			ver2[i]=0
		fi
		if ((10#${ver1[i]} > 10#${ver2[i]})); then
			# version1 > version2
			return 1
		fi
		if ((10#${ver1[i]} < 10#${ver2[i]}));
		then
			# version1 < version2
			return 2
		fi
	done
	return 0
}

# Checks githelpertools version on <branch>
# Usage _ght_checkversion [-v|--verbose] branch
_ght_checkversion()
{
	local verbose="false"
	local branch="master"
	local new_version
	local ec

	if [[ x"$1" == x--verbose || x"$1" == x-v ]]; then
		verbose="true"
		shift
	fi
	[ -n "$1" ] && branch="$1"

	new_version=`_ght_geturl`
	_ght_vercomp $__ght_version $new_version
	ec=$?
	if [ $verbose == "true" ]; then
		[ $ec -eq 2 ] && echo -e "New version \e[44m$new_version\e[0m is available!"
	fi
	[ $ec -eq 2 ] && _ght_log_core "New version $new_version" || _ght_log_core "No new version"
	return $ec
}

# Downloads <url> to <file> or to stdout with wget or curl
# Usage _ght_geturl <url> <file>
_ght_geturl()
{
	local ec
	local temp_dir_list="/tmp $TMP $TEMP"
	local tmp_std_out
	local tmp_std_err=/dev/null
	local url
	local out_file
	local timeout=5
	local retry=2

	if [ -n "$1" ]; then
		url="$1"
		shift
	else
		url=`_ght_getconfig checkurl`
		url=${url//%b/`_ght_getconfig updatebranch`}
	fi

	[ -n "$1" ] && out_file="$1"

	for item in $temp_dir_list
	do
		if [ -d "$item" ]; then
			tmp_std_out="$item/ght-`_ght_rndstr`"
			tmp_std_err="$item/ght-`_ght_rndstr`"
			break
		fi
	done
	[ -z $tmp_std_out ] && return 1

	if type -ft wget &> /dev/null; then
		wget -qO $tmp_std_out --timeout=$timeout --tries=$retry --no-check-certificate $url 2> $tmp_std_err
	elif type -ft curl &> /dev/null; then
		curl -so $tmp_std_out --connect-timeout $timeout --retry $retry --insecure $url 2> $tmp_std_err
	else
		return 1
	fi

	[ -n "`cat $tmp_std_err`" ] && _ght_log_core "`cat $tmp_std_err`"

	if [[ -n "$out_file" && "$out_file" != "-" ]]; then
		cp -f "$tmp_std_out" "$out_file" &> /dev/null
		ec=$?
	else
		cat "$tmp_std_out" &> /dev/null
		ec=$?
	fi

	rm -f "$tmp_std_out" "$_tmp_std_err" &> /dev/null
	return $ec
}

# Registers core modules and user plugins
# Usage _ght_register <module_name>
_ght_register()
{
	local reg_name=${1%.*}

	"$__ght_git_cmd" config --unset-all alias.$reg_name 2> /dev/null
	"$__ght_git_cmd" config --global alias.$reg_name ght_$reg_name
	return 0
}

# Get or check OS type
# Usage _ght_shelltype [LINUX|BSD|MINGW|CYGWIN|UWIN|MAC]
_ght_shelltype()
{
	local os_type=`uname -s`

	[ `uname -s | egrep -i "linux"` ] && os_type="LINUX"
	[ `uname -s | egrep -i "bsd"` ] && os_type="BSD"
	[ `uname -s | egrep -i "mingw"` ] && os_type="MINGW"
	[ `uname -s | egrep -i "cygwin"` ] && os_type="CYGWIN"
	[ `uname -s | egrep -i "uwin"` ] && os_type="UWIN"
	[ `uname -s | egrep -i "darwin"` ] && os_type="MAC"
	[ -z $1 ] && echo $os_type || [ "$1" == "$os_type" ]
	return $?
}

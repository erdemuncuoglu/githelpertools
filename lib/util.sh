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
	local file=`_ght_lastparam $params`
	
	[ -e $file ] && return 1
	touch $params &> /dev/null && return 0
	_ght_mkdir `dirname "$file"`
	[ $? -eq 0 ] && touch $params || return 1
	return $?
}

# Ehanced version of command mkdir
# Usage _ght_mkdir dirname
_ght_mkdir()
{
	local dir="$1"
	
	[ -z $dir -o $dir == "." -o $dir == "/" -o -e $dir ] && return 1
	mkdir $dir &> /dev/null
	[ $? -eq 0 ] && return 0
	_ght_mkdir `dirname "$dir"`
	[ $? -ne 0 ] && return 1
	mkdir $dir
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
	
	#new_version=$(wget -qO- --no-check-certificate https://raw.github.com/erdemuncuoglu/githelpertools/$branch/VERSION 2> /dev/null)
	new_version=$(_ght_geturl https://raw.github.com/erdemuncuoglu/githelpertools/$branch/VERSION)
	_ght_vercomp $__ght_version $new_version
	ec=$?
	if [ $verbose == "true" ]; then
		[ $ec -eq 2 ] && echo "New version $new_version is available."
	fi
	return $ec
}

# Downloads <url> to <file> or to stdout with wget or curl
# Usage _ght_geturl url file
_ght_geturl()
{
	local ec
	local temp_dir_list="/tmp $TMP $TEMP"
	local temp_file
	local url=$1
	local out_file=$2
	
	[ -z $url ] && return 1
	
	for item in $temp_dir_list
	do
		if [ -d "$item" ]; then
			temp_file=$item/`_ght_rndstr`
			break
		fi
	done
	[ -z $temp_file ] && return 1
	
	if [ `type -fp wget` ]; then
		wget -qO $temp_file --no-check-certificate $url 2> /dev/null
	elif [ `type -fp curl` ]; then
		curl -so $temp_file --insecure $url 2> /dev/null
	else
		return 1
	fi
	
	if [[ -n $out_file && $out_file != "-" ]]; then
		cp -f $temp_file $out_file
		ec=$?
	else
		cat $temp_file
		ec=$?
	fi
	
	rm -f $temp_file
	return $ec
}

# Registers core modules and user plugins
# Usage _ght_register module_name
_ght_register()
{
	local reg_name=${1%.*}
	
	git config --unset-all alias.$reg_name 2> /dev/null
	git config --global alias.$reg_name ght_$reg_name
	return 0
}

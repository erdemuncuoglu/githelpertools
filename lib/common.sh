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


tool_name="gitHelperTools"
tool_version=$(cat $self_dir/VERSION)

# usage __split variable index delimiter
__split()
{
	local list
	local ind
	local sep
	local pos
	
	[ -z "$1" ] && return 1 || list="$1"
	[ -z "$2" ] && ind="1" || ind="$2"
	[ -z "$3" ] && sep="=" || sep="$3" 
	
	#pos=`__strindex "$list" "$sep"`
	#[ $pos -eq -1 ] && return 1
	
	#[ $ind -eq 1 ] && echo ${list:0:$pos} || echo ${list:$((pos + 2))}
	echo $list | cut -d $sep -f $ind
	return 0
}

# usage __strindex string substring
__strindex()
{
	x="${1%%$2*}"
	[[ "$x" = "$1" ]] && echo -1 || echo ${#x}
}

# usage __rpad string length padchar
__rpad()
{
	__pad "$1" "$2" right "$3"
	return $?
}

# usage __lpad string length padchar
__lpad()
{
	__pad "$1" "$2" left "$3"
	return $?
}

# usage __pad string length direction padchar
__pad()
{
	local str="$1"
	local length="$2"
	local dir="$3"
	local pchr
	local pstr
	local ec=1
	
	[ $# -lt 3 ] && return $ec
	[ -z $4 ] && pchr=" " || pchr="$4"
	pstr=`__repeat "$((length - ${#str}))" "$pchr"`
	if [ "$dir" == "left" ]; then
		echo "$pstr$str"
		ec=0
	fi
	if [ "$dir" == "right" ]; then
		echo "$str$pstr"
		ec=0
	fi
	return $ec
}

# usage __repeat length char
__repeat()
{
	local length
	local char
	local str
	
	[ -z "$1" ] && return 1 || length="$1"
	[ $length -lt 1 ] && return 1
	[ -z "$2" ] && char=" " || char="$2"
	
	str=`printf "%*s" $length`
	echo "${str// /$char}"
}

# usage __nthparam paramindex params...
__nthparam()
{
	#TODO
	local ind=$1
	shift
	local params=$@
}

# usage __lastparam params...
__lastparam()
{
	local len=$#
	
	[ $len -eq 0 ] && return 1
	while [ $len -gt 1 ]; do
		shift
	done
	echo $1
	return 0
}

# usage __touch (same parameters as touch command.)
# Try `touch --help' for more information.
__touch()
{
	local params="$@"
	local file=`__lastparam $params`
	
	[ -e $file ] && return 1
	touch $params &> /dev/null && return 0
	__mkdir `dirname "$file"`
	[ $? -eq 0 ] && touch $params || return 1
	return $?
}

# usage __mkdir dirname
__mkdir()
{
	local dir="$1"
	
	[ -z $dir -o $dir == "." -o $dir == "/" -o -e $dir ] && return 1
	mkdir $dir &> /dev/null
	[ $? -eq 0 ] && return 0
	__mkdir `dirname "$dir"`
	[ $? -ne 0 ] && return 1
	mkdir $dir
	return $?
}

# usage __vercomp version1 version2
# source <http://stackoverflow.com/a/4025065>
__vercomp()
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

# usage __checkversion [-v|--verbose] branch
__checkversion()
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
	
	new_version=$(wget -qO- --no-check-certificate https://raw.github.com/erdemuncuoglu/githelpertools/$branch/VERSION 2> /dev/null)
	__vercomp $tool_version $new_version
	ec=$?
	if [ $verbose == "true" ]; then
		[ $ec -eq 2 ] && echo "New version $new_version is available."
	fi
	return $ec
}

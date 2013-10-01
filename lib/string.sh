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



# Returns <list> element at zero based <index> delimited by <delimiter>
# Usage _ght_split list index delimiter
_ght_split()
{
	local list
	local ind
	local sep
	local pos
	
	[ -z "$1" ] && return 1 || list="$1"
	[ -z "$2" ] && ind="0" || ind="$2"
	[ -z "$3" ] && sep="=" || sep="$3"
	
	echo $list | cut -d $sep -f $((ind + 1))
	return 0
}

# Returns zero based position of <substring> in a <string> or '-1' if not found
# Usage _ght_strindex string substring
_ght_strindex()
{
	x="${1%%$2*}"
	[[ "$x" = "$1" ]] && echo -1 || echo ${#x}
}

# Right pads given <string> to the given <length> with given <padchar>
# Usage _ght_rpad string length padchar
_ght_rpad()
{
	_ght_pad "$1" "$2" right "$3"
	return $?
}

# Left pads given <string> to the given <length> with given <padchar>
# Usage _ght_lpad string length padchar
_ght_lpad()
{
	_ght_pad "$1" "$2" left "$3"
	return $?
}

# Pads given <string> to the given <length> with given <padchar> in given <direction>
# Usage _ght_pad string length direction padchar
_ght_pad()
{
	local str="$1"
	local length="$2"
	local dir="$3"
	local pchr
	local pstr
	local ec=1
	
	[ $# -lt 3 ] && return $ec
	[ -z $4 ] && pchr=" " || pchr="$4"
	pstr=`_ght_repeat "$((length - ${#str}))" "$pchr"`
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

# Returns <char> repeated <length> times
# Usage _ght_repeat length char
_ght_repeat()
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

# Trims whitespace from left side of a <string>
# Usage _ght_ltrim string
_ght_ltrim()
{
	local trimmed=`echo "$@" | sed -e 's/^[[:space:]]*//g'`
	local ec=$?
	
	echo $trimmed
	return $ec
}

# Trims whitespace from right side of a <string>
# Usage _ght_ltrim string
_ght_rtrim()
{
	local trimmed=`echo "$@" | sed -e 's/[[:space:]]*$//g'`
	local ec=$?
	
	echo $trimmed
	return $ec
}

# Trims whitespace from both sides of a <string>
# Usage _ght_trim string
_ght_trim()
{
	local trimmed=$(_ght_rtrim `_ght_ltrim "$@"`)
	local ec=$?
	
	echo $trimmed
	return $ec
}

# Creates a random string of <length> between 1 and 32
# Usage _ght_rndstr length
_ght_rndstr ()
{
	local length=$1
	local rnd_str
	
	[[ -z $length || $length < 1 || $length > 32 ]] && length=32
	
	rnd_str=`echo $RANDOM | md5sum | md5sum`
	rnd_str=${rnd_str:0:$length}
	echo $rnd_str
	return 0
}

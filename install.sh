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


echo " * Preparing Installer..."

nanosec="false"
ta=`date +%s%N`
[ ${ta/\%N/} == $ta ] && nanosec="true" || ta=${ta/\%N/}

__ght_self_dir=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd`

[ -f "$__ght_self_dir/lib/base.sh" ] && . "$__ght_self_dir/lib/base.sh" || exit 1

[ x"$1" == x--update ] && echo " * Updating to v$__ght_version" || echo " * Installing $__ght_name v$__ght_version"

if _ght_shelltype MINGW; then
	git_completion=/etc/git-completion.bash
	git_prompt=/etc/git-prompt.sh
	bash_rc=~/.bashrc
	temp_rc=~/temp.bashrc
elif _ght_shelltype MAC; then
	# TODO: MAC OS implementation assigned to Mert KAYA
	# git_completion=/etc/git-completion.bash
	# git_prompt=/etc/git-prompt.sh

	# TODO: on MAC use .profile instead .bashrc
	# bash_rc="$HOME/.bashrc"
	# temp_rc="$HOME/temp.bashrc"
	false
elif _ght_shelltype LINUX; then
	git_completion=~/.git-completion.sh
	git_prompt=~/.git-prompt.sh
	bash_rc=~/.bashrc
	temp_rc=~/temp.bashrc
else
	echo "new shell : "`_ght_shelltype`
	exit 1
fi

echo " * Downloading 'git-prompt.sh' and 'git-completion.bash'"
_ght_geturl https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh "$git_completion"
_ght_geturl https://raw.github.com/git/git/master/contrib/completion/git-completion.bash "$git_prompt"

inst_line="source \"$__ght_self_dir/githelper.sh\" # $__ght_name v$__ght_version"

[ -e "$temp_rc" ] && rm -f $temp_rc
[ ! -e "$bash_rc" ] && _ght_touch $bash_rc
mkdir -p "$__ght_self_dir/user"
mkdir -p "$__ght_self_dir/plugins"
mkdir -p "$__ght_self_dir/log"

if [ -w "$bash_rc" ]; then
	echo " * Updating '`basename "$bash_rc"`'"
	cp -f "$bash_rc" "$bash_rc~"
	_ght_touch "$temp_rc"
	IFS="■"
	while read -r line
	do
		ignore="false"
		for skipstr in git-completion git-prompt $__ght_name
		do
			if [[ "$line" == *"$skipstr"* ]]; then
				ignore="true"
				break
			fi
		done
		[ "$ignore" == "false" ] && echo $line >> "$temp_rc"
	done < "$bash_rc"

	# TODO: what if MAC or else ?
	#if _ght_shelltype LINUX; then
	#	echo 'source "'$git_completion'"' >> "$temp_rc"
	#	echo 'source "'$git_prompt'"' >> "$temp_rc"
	#fi

	echo $inst_line >> "$temp_rc"
	mv -f "$temp_rc" "$bash_rc"

	echo " * Updating git aliases"
	while IFS= read -d $'\n' -r alias_file
	do
		while read -r git_alias
		do
			alias_name=$(_ght_trim `_ght_split "$git_alias" 0`)
			alias_cmd=$(_ght_trim `_ght_split "$git_alias" 1`)

			git config --global --unset-all alias.$alias_name
			if [ "$alias_cmd" != "false" ]; then
				git config --global alias.$alias_name "$alias_cmd"
				echo "    alias $alias_name = $alias_cmd"
			fi
		done < "$alias_file"
	done <<<"$(find "$__ght_self_dir/conf" "$__ght_self_dir/user" -iname "*.alias" -print)"

	tb=`date +%s%N`
	[ $nanosec == "false" ] && tb=${tb/\%N/}
	td=$((tb - ta))
	[ $nanosec == "true" ] && td=$((td / 1000000))"ms" || td=$td"s"
	echo "Completed in $td."
	echo
	[ x"$1" != x--update ] && echo "Run 'exec bash -l' to activate changes"
	exit 0
fi

echo " * Installation failed!"
exit 1

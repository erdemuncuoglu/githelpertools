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

echo "Preparing Installer..."

self_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git_completion=
git_prompt=

if [ `uname -s | grep -i "mingw"` ]; then
	if [ ! `type -fp wget` ]; then
		cp -f $self_dir/extension/wget/bin/* /bin/
		cp -f $self_dir/extension/wget/etc/* /etc/
	fi
	wget --no-check-certificate -qO /etc/git-prompt.sh https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh 2> /dev/null
	wget --no-check-certificate -qO /etc/git-completion.bash https://raw.github.com/git/git/master/contrib/completion/git-completion.bash 2> /dev/null
elif [ `uname -s | grep -i "darwin"` ]; then
	# TODO MAC OS implementation assigned to Mert KAYA
	false
else
	wget --no-check-certificate -qO $HOME/git-prompt.sh https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh 2> /dev/null
	wget --no-check-certificate -qO $HOME/git-completion.sh https://raw.github.com/git/git/master/contrib/completion/git-completion.bash 2> /dev/null
	git_completion="git-completion.sh"
	git_prompt="git-prompt.sh"
fi

[ -f $self_dir/lib/common.sh ] && . $self_dir/lib/common.sh || exit 1

# TODO on MAC use .profile instead .bashrc
bash_rc="$HOME/.bashrc"
temp_rc="$HOME/temp.bashrc"
inst_line="source $self_dir/githelper.sh # $tool_name v$tool_version"
alias_file="$self_dir/conf/core.alias"

[ x"$1" == x--update ] && echo "  Updating to v$tool_version" || echo "  Installing $tool_name v$tool_version"
[ -e $temp_rc ] && rm -f $temp_rc
[ ! -e $bash_rc ] && __touch $bash_rc

if [ -w $bash_rc ]; then
	ta=`date +%s`
	echo "  Updating $bash_rc"
	cp $bash_rc $bash_rc~
	__touch $temp_rc
	while read -r line; do
		ignore="false"
		for skipstr in $git_completion $git_prompt $tool_name; do
			if [[ "$line" == *"$skipstr"* ]]; then
				ignore="true"
				break
			fi
		done
		[ "$ignore" == false ] && echo "$line" >> $temp_rc
	done < $bash_rc
	[ -n "$git_completion" ] && echo "source ~/$git_completion" >> $temp_rc
	[ -n "$git_prompt" ] && echo "source ~/$git_prompt" >> $temp_rc
	echo "$inst_line" >> $temp_rc
	cat $temp_rc > $bash_rc
	rm -f $temp_rc
	
	echo "  Updating git aliases"
	while read -r git_alias; do

		alias_name=`__split "$git_alias" 1`
		alias_cmd=`__split "$git_alias" 2`

		git config --global --unset-all alias.$alias_name
		if [ "$alias_cmd" != "false" ]; then
			git config --global alias.$alias_name "$alias_cmd" 
			echo -n "    alias $alias_name"
			[ "$alias_cmd" != "true" ] && echo -n " = $alias_cmd"
			echo
		fi
	done < $alias_file
	tb=`date +%s`
	echo "Completed in $((tb - ta))s."
	echo
	[ x"$1" != x--update ] && echo "Run 'exec bash -l' to activate changes"
	exit 0
fi

echo "...failed!"
exit 1

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


function __gitupd() {

	curbranch=`git branch | grep "*" | sed "s/* //"`
	
	branches=`git branch | sed "s/* //"`
	lines=`wc -l <<< "$branches"`
	lines=`echo $lines | sed "s/	//"`
	
	ind=1
	while read branch; do
	
		echo -e "\e[01mBranch :\e[0m \e[44m$branch\e[0m \e[41m($ind/$lines)\e[0m"
		git checkout $branch &> /dev/null
		ec=$?
		if [[ $ec -eq 0 ]]; then
			git pull origin master
			ec=$?
			if [[ $ec -eq 0 ]]; then
				if [[ $1 == "-f" || $1 == "-p" && $branch != master ]]; then
					git push origin $branch
				else
					echo -e "\e[5;31mSkipping\e[0m git push origin $branch"
				fi
			else
				echo -e "\e[5;31mError $ec\e[0m at git pull origin master"
			fi
		else
			echo -e "\e[5;31mError $ec\e[0m at git checkout $branch"
		fi
		echo "------------------------------------------------------------------------------"
		
		ind=$(( ind + 1 ))
	done <<< "$branches"
	
#	echo -e "\e[01mBranch :\e[0m \e[44m$curbranch\e[0m"
	git checkout $curbranch &> /dev/null
	return 0
}

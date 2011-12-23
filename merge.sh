#!/bin/bash
# merge
# merges one git branch into another

. /etc/git-completion.bash


STYLE_BRIGHT=$'\033[1m'
STYLE_DIM=$'\033[2m'
STYLE_NORM=$'\033[0m'
COL_RED=$'\033[31m'
COL_GREEN=$'\033[32m'
COL_VIOLET=$'\033[34m'
COL_YELLOW=$'\033[33m'
COL_MAG=$'\033[35m'
COL_CYAN=$'\033[36m'
COL_WHITE=$'\033[37m'
COL_NORM=$'\033[39m'

current_branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

echo "##########################################"
echo "Merging from ${COL_YELLOW}$1${COL_NORM} into ${COL_CYAN}$3${COL_NORM}"
echo "##########################################"
echo
echo

branchprotected_nomergefrom=`grep "$1" ${gitscripts_path}../protected_branches_nomergefrom`
echo "branchprotected_nomergefrom: ${branchprotected_nomergefrom}"
if [ -n "$branchprotected_nomergefrom" ]
	then
	echo
	echo "${COL_RED}WARNING: merging ${COL_YELLOW}from${COL_RED} ${COL_CYAN}$1${COL_RED} not allowed. You may only merge ${COL_YELLOW}INTO ${COL_CYAN}$1${COL_NORM}."
	echo
	echo
	return -1
fi

branchprotected_nomergeto=`grep "$3" ${gitscripts_path}../protected_branches_nomergeto`
echo "branchprotected_nomergeto: ${branchprotected_nomergeto}"
if [ -n "$branchprotected_nomergeto" ]
	then
	echo
	echo "${COL_RED}WARNING: merging ${COL_YELLOW}into${COL_RED} ${COL_CYAN}$3${COL_NORM} not allowed.${COL_NORM}"
	echo "${COL_RED}You may only merge ${COL_YELLOW}FROM${COL_RED} ${COL_CYAN}$3${COL_NORM}.${COL_NORM}"
	echo
	echo
	return -1
fi




if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	return -1
fi

echo This tells your local git about all changes on fl remote
echo git fetch --all --prune
git fetch --all --prune

if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git fetch --all --prune failed"
	return -1
fi

echo
echo
echo This checks out the $1 branch
echo git checkout $1
${gitscripts_path}checkout.sh $1
result=$?

if [ $result -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "checkout of branch $1 failed"
	return -1
elif [ $result -eq 255 ]
	then
	echo "Checking out the branch $1 was unsuccessful, aborting merge attempt..."
	return -1
fi

echo
echo
echo This checks out the $3 branch
echo git checkout $3
${gitscripts_path}checkout.sh $3
result=$?

if [ $result -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git checkout $3 failed"
	return -1
elif [ $result -eq 255 ]
	then
	echo "Checking out the branch $3 was unsuccessful, aborting merge attempt..."
	return -1
fi

echo
echo
echo This merges from $1 into $3
echo git merge --no-ff $1
git merge --no-ff $1

if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git merge --no-ff $1 failed"
	return -1
fi

statusofmerge=`git status | grep "Unmerged paths"`

if [[ "$statusofmerge" == "# Unmerged paths:" ]];
	then
		echo
		git status
		echo

		echo
		echo "${COL_YELLOW}WARNING: You have unmerged paths!${COL_NORM}"
		echo
		echo "Please ${COL_RED}resolve your merge conflicts${COL_NORM} , then ${COL_YELLOW}run a build and test your build before pushing${COL_NORM} back out.${STYLE_NORM}"
		echo
		echo "Would you like to run the merge tool? (y) n"
		read YorN
		if [ "$YorN" != "n" ]
			then

				git mergetool
			else
				return -1
		fi
fi

statusofmerge=`git status | grep "Changes to be committed"`

if [[ "$statusofmerge" == "# Changes to be committed:" ]];
	then
		echo
		git status
		echo

		echo "${COL_YELLOW}WARNING: You have uncommitted changes!${COL_NORM}"
		echo
		echo "Please ${COL_RED}add/commit${COL_NORM} any changes you have.${STYLE_NORM}"
		echo "Would you like to commit these changes? (y) n"
		read YorN
		if [ "$YorN" != "n" ]
			then
				echo "please enter a commit message"
				read commitmessage

				source ${gitscripts_path}commit.sh "$commitmessage" -a

			else
				return -1
		fi
fi

echo
echo
echo git status
git status
echo
echo "Would you like to push? y (n)"
read YorN
if [ "$YorN" = "y" ]
	then
	remote=$(git remote)
	git push $remote head

	#offer to delete dev/dev2/qa for them if they push since they may no longer need it
	if [ -n "$branchprotected_nomergefrom" ]
	then
		if [ "$3" != "$current_branch" ]
			then
			echo
			echo
			echo "Would you like to delete ${COL_CYAN}$3${COL_NORM} and check ${COL_CYAN}$current_branch${COL_NORM} back out? y (n)"
			read decision
			if [ "$decision" = "y" ]
				then
				echo
				echo
				echo "checking out ${COL_CYAN}$current_branch${COL_NORM}"
				${gitscripts_path}checkout.sh $current_branch

				echo
				echo
				echo "deleting ${COL_CYAN}$3${COL_NORM}"
				${gitscripts_path}delete.sh $3
			fi
		fi
	fi
else
	if [ "$3" != "$current_branch" ]
		then
		echo
		echo
		echo "Would you like to check ${COL_CYAN}$current_branch${COL_NORM} back out? y (n)"
		read decision
		if [ "$decision" = "y" ]
			then
			echo
			echo
			echo "checking out ${COL_CYAN}$current_branch${COL_NORM}"
			${gitscripts_path}checkout.sh $current_branch
		fi
	fi
fi

if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git push ${COL_CYAN}$remote $3${COL_NORM} failed"
	return -1
fi




## IN PROGRESS/NOT STABLE

*NOTE:* This library is currently in progress. Not ready for use.

git-hug is a collection of shell scripts that simplify and streamline the use of Git. git-hug does not replace Git, nor does it aim to. It's kind of a wrapper for Git, or more, an extension to Git's built-in commands. In short, these scripts and Git are locked in a nice, warm hug.  =]

 If you install git-hug, you can still access all of your git commands exactly the same way you used to. However, now you have an extra library of commands at your disposal.


### Compatibility

These scripts were built in OS X 10.9 and should work in any Bash shell 3.2.51+.  You may feel free to test them in other shells and drop me a line with the results.


### Dependencies

The only hard dependency for git-hug is [functionsh](https://github.com/Smolations/functionsh), which is a collection of helper functions for Bash development. However, there is built-in support for colors if you happen to have [colorsh](https://github.com/Smolations/colorsh) installed. The documentation for git-hug functions and commands are written using the convention defined by the [myman](https://github.com/Smolations/myman) documentation generator. Don't worry, if you don't have myman, you will still have access to usage definitions for git-hug. Keep reading!


# Installation

Clone the repo somewhere on your machine:

    $ git clone git@github.com:Smolations/git-hug.git

You will need to modify your `~/.bash_profile` or `~/.bashrc` file (assuming it's already sourced in `~/.bash_profile`). Add the following line to the file:

    source /path/to/git-hug/SOURCEME

So, if your local git-hug repo is in `~/projects/git-hug`, you would add:

    source ~/projects/git-hug/SOURCEME



### Configuration Notes

git-hug comes with some intelligent defaults, so, this is for those that are just not satisfied with defaults.

Any config adjustments you want to make should be made in a file that you create:

    cp cfg/user.overrides.example cfg/user.overrides

This file is ignored by default, so, mod away!



# Usage

While usage instructions are provided here, you can display them in your terminal by issuing the following command:

    $ git-hug usage [command]

Without a given `[command]`, git-hug will display usage for ALL commands.


### Status

The most basic example is as follows. To see which files have changes, you would normally type:

    git status

With git-hug you can just do:

    status


### Commit

Say you have changes to 5 tracked files that you want to commit. Normally you would have to do the following:

    git commit -a -m "my comments on my changes"

With git-hug you can just do:

    commit -a "my comments on my changes"


I know, these doesn't seem much different. But it *did* save just a little bit of time. Two paper cuts.


### New Branch

Here's where the real magic happens though. Let's say you want to create a new branch. Normally you would have to do all of the following (if being safe):

    git status
    #if you have changes
        git stash (or) git add -A, git commit -m "your commit"
        git push origin branch
    #check out the branch you want to fork
    git checkout master
    #make sure it is up to date
    git fetch --all --prune
    git pull origin master
    #now, finally, make the branch
    git checkout -b newbranch


Whew! OK, with gitscripts, you just do:

    new branch from branch


That's it. It jumps into an intelligent guided numeric menu driven process that does everything that you would normally have to do by hand with nominal intervention from you only when absolutely necessary with intelligent defaults so that 90% of the time you are just hitting "Enter".


### Merge

Let's say you want to merge two branches. Normally you would have to do all of the following (if being safe):

    git status
    #if you have changes
        git stash (or) git add -A, git commit -m "your commit"
        git push origin branch
    #make sure both branches are up to date
    git fetch --all --prune
    git checkout branchtomergefrom
    git pull origin branchtomergefrom
    git checkout branchtomergeto
    git pull origin branchtomergeto
    git merge --ff branchtomergefrom
    #resolve conflicts and then
    git add .
    git commit -m "merging branchtomergefrom"
    git push origin branchtomergeto

Yikes! Again, git-hug to the rescue! Here's what you would do in git-hug:

    merge branchtomergefrom into branchtomergeto


### More

There are many other things that git-hug does for you. Here is an incomplete list of commands:

* add [filename] - Will determine if git add or git rm needs run, and then runs it for the provided file. If no file provided, presents you with a menu of unstaged files.
* branch - Will present a numbered list of all branches. Optionally allows you to select a branch to checkout
* checkout [branchname] - Supports tab completion on branch names. Will present a numbered list of branches for you to select one to checkout. Auto-merges master and pulls latest from remote.
* clean-branches - determine which branches are already merged with master and prompt for you to delete them
* commit - Commit with implicit -m flag, prompts for -a or -A, pushes changes to remote
* contains [branch]- Searches through branches to determine which ones contain do/don't contain the branch (defaults to current branch)
* cpafter - Allows you to specify date and to/from directories. Will copy all files modified after specified date in specified directory to specified directory
* delete <branch> - Deletes branch and prompts for deletion on remote
* gitdiff [branch] - shows all differences between current branch and specified branch in concise manner and then prompts for verbose manner
* gitdifftool [branch] - same as gitdiff, but, runs your gitdiff tool to show differences
* merge <branch> [into branch] - Merges master into both, pulls remotes for both, then merges the first into the second and prompts for push to remote
* new <branch> [from branch] - Creates new branch from master or from specified branch. Updates the starting branch first. Prompts for push after
* pull [branch] - Pull changes form remote for specified branch as well as merges latest version of master
* pullscripts - updates gitscripts!
* push - Pushes changes from current branch up to remote
* trackbranch <branch> [upstream/branch] - Allows you to set the upstream (remote repo) for a branch
* update - Pulls changes from remote and merges master

:D




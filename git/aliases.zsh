# Use `hub` as our git wrapper:
# http://defunkt.github.com/hub/
hub_path=$(which hub)
if (( $+commands[hub] ))
then
 alias git=$hub_path
fi

alias ga='git add -A .'
alias gb=fnGitBranch
alias gd=fnGitDelete
alias gdf=fnGitDeleteFeature
alias gbm=fnGitBranchMaster
alias go=fnGitCheckout
alias gol=fnGitCheckoutPull
alias gc=fnGitCommit
alias gch=fnGitCommitPush
alias gi='git diff'
alias gf='git fetch --all'
alias gr='git reset --hard'
alias gm=fnGitMerge
alias gn='git pull --prune && gb'
alias gg=fnGitLog
alias ggv=fnGitLogVerbose
alias gl='git pull'
alias gh='git push'
alias gs='git status -sb'
alias gt='git stash'
alias gta='git stash apply'

fnGitBranch() {
    if (( $# == 0 ))
    then
        git branch -a
    else
        git pull
        git branch feature/$1
        git checkout feature/$1
        git push -u origin feature/$1
    fi
}

fnGitDelete() {
    if (( $# == 0 ))
    then
        echo "\n    Usage: gd <branch-to-delete> ..."
    else
        git branch -D $*
        fnGitBranch
    fi
}

fnGitDeleteFeature() {
    if (( $# == 0 ))
    then
        echo "\n    Usage: gd <branch-to-delete> ..."
    else
        git branch -D feature/$*
        fnGitBranch
    fi
}

fnGitBranchMaster() {
    if (( $# == 0 ))
    then
        git branch -a
    else
        git checkout master
        git pull
        git branch feature/$1
        git checkout feature/$1
        git push -u origin feature/$1
    fi
}

fnGitCheckout() {
    if (( $# == 0 ))
    then
        git checkout master
    else
        git checkout feature/$1
    fi
}

fnGitCheckoutPull() {
    fnGitCheckout
    git pull
}

fnGitCommit() {
    git add --all
    git commit -m "$1"
}

fnGitCommitPush() {
    if (( $# == 0 ))
    then
        echo "commit what sucka?!"
    else
      fnGitCommit $1
      git pull
      git push
    fi
}

fnGitMerge() {
    if (( $# == 0 ))
    then
        git pull
        git merge master
    else
        git merge $1
    fi
}

fnGitLog() {
    if (( $# == 0 ))
    then
        git log --decorate --graph --oneline -n 10
    else
        git log --decorate --graph --oneline -n $1
    fi
}

fnGitLogVerbose() {
    if (( $# == 0 ))
    then
        git log --decorate --graph -n 10
    else
        git log --decorate --graph -n $1
    fi
}

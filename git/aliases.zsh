# Use `hub` as our git wrapper:
# http://defunkt.github.com/hub/
hub_path=$(which hub)
if (( $+commands[hub] ))
then
 alias git=$hub_path
fi

alias ga=fnGitAdd
alias gb=fnGitBranch
alias gd=fnGitDelete
alias gdf=fnGitDeleteFeature
alias gbm=fnGitBranchMaster
alias go=fnGitCheckout
alias gol=fnGitCheckoutPull
alias gc=fnGitCommit
alias gch=fnGitCommitPush
alias gi='git diff'
alias gf='git fetch --all && gb'
alias gr=fnGitReset
alias gm=fnGitMerge
alias gn=fnGitPrune
alias gg=fnGitLog
alias ggv=fnGitLogVerbose
alias gl='git pull'
alias gh='git push'
alias gs='git status -sb'
alias gt='git stash'
alias gta='git stash apply'

fnGitAdd() {
  git add -A .
}

# Does a hard reset with double confirmation if there are uncommitted changes.
fnGitReset() {
  uncommitted_changes=($(git status -s))

  if (( ${#uncommitted_changes[@]} == 0 )) then
    git reset --hard
  else
    echo ""
    echo "Uncommited chagnes:"
    git status -s
    
    echo ""
    read -q "CONFIRM?PERMANENTLY loose uncommitted changes above? (y/N) "

    if [[ $CONFIRM == "y" ]] then
      echo ""
      read -q "CONFIRM_AGAIN?You're aware there exists no black magic that can bring these back? (y/N) "
      echo ""
    
      if [[ $CONFIRM_AGAIN == "y" ]] then
        git reset --hard
      fi
    fi
  fi
  
  unset uncommitted_changes
  unset CONFIRM
  unset CONFIRM_AGAIN
}

fnGitPrune() {
  # make sure we're in a git repo
  if [[ $(fnIsGitRepo) != "true" ]] then
    return false
  fi

  # save current branch
  original_branch=$(git branch | grep "* ");
  original_branch=${original_branch/"* "};

  git checkout master

  # trim fetched to match remotes
  git pull --prune

  #                    +merged branches      -current       -specific
  branches_to_delete=$(git branch --merged | grep -v "\*" | egrep -v "master")

  # array from lines
  branches_to_delete=("${(f)branches_to_delete}")

  # if there are branches to delete (1 blank line always exists), confirm and delete
  if (( ${#branches_to_delete[@]} > 1 )) then
    echo "\nLocal branches already merged:"
    # list branches
    for branch in $branches_to_delete; do
      echo "$branch"
    done
    
    echo ""
    read -q "CONFIRM?Delete ALL these? (y/N) "
    echo ""
  
    if [[ $CONFIRM == "y" ]]
      then
        # delete branches
        for branch in $branches_to_delete; do
          git branch -d ${branch// /}
        done
        
      else
        echo "\nCancelled"
    fi
  fi

  git checkout $original_branch

  unset branches_to_delete
  unset original_branch
}

fnGitBranch() {
  if (( $# == 0 )) then
    git branch -a
  else
    git pull
    git branch feature/$1
    git checkout feature/$1
    git push -u origin feature/$1
  fi
}

fnGitDelete() {
  if (( $# == 0 )) then
    echo "\n  Usage: gd <branch-to-delete> ..."
  else
    git branch -D $*
    fnGitBranch
  fi
}

fnGitDeleteFeature() {
  if (( $# == 0 )) then
    echo "\n  Usage: gd <branch-to-delete> ..."
  else
    git branch -D feature/$*
    fnGitBranch
  fi
}

fnGitBranchMaster() {
  if (( $# == 0 )) then
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
  # make sure we're in a git repo
  if [[ $(fnIsGitRepo) != "true" ]] then
    return false
  fi

  # get query from arg 1 or wild card
  if (( $# > 0 )) then
    go_query=$1
  else
    go_query="."
  fi
  
  # use args 2+ as branch options array (for recursive narrowing)
  if (( $# > 1 )) then
    set -A go_branches ${@:2}
  else
    # get branches, excluding current
    go_branches=$(git branch | grep -v "\*")
  
    # array from lines
    go_branches=("${(f)go_branches}")
  fi

  go_counter=1
  go_matches=()
  for go_branch in $go_branches; do
    # replace spaces
    go_branch=${go_branch//" "}
    
    # if branch contains query
    if [[ $go_branch =~ $go_query ]] then;
      # add to array
      go_matches[$go_counter]=$go_branch
    
      # print index & name
      echo "$go_counter: $go_branch"
    
      # increment counter
      go_counter=$((go_counter+1))
    fi
  done;
  
  # 0 matches - rerun with no query, showing all options
  if (( ${#go_matches[@]} == 0 )) then
    fnGitCheckout
    return false
  fi

  # 1 match, save it
  if (( ${#go_matches[@]} == 1 )) then
    go_checkout=$go_matches[1]
  fi
    
  # >1 match, prompt for input
  if (( ${#go_matches[@]} > 1 )) then
    echo ""
    read "go_input?(query/#): "
    
    # if input, attempt select branch from array by index
    if [[ $go_input != "" ]] then
      go_checkout=$go_matches[$go_input]
    fi

    # if input did not result in a valid branch index
    # rerun with input as query against matches
    if [[ $go_checkout == "" ]] then
      fnGitCheckout $go_input $go_matches
      return false
    fi
  fi
  
  git checkout ${go_checkout}

  unset go_query
  unset go_branches
  unset go_counter
  unset go_branch
  unset go_matches
  unset go_checkout
  unset go_input
}

fnGitCheckoutPull() {
  fnGitCheckout $1
  git pull
}

fnGitCommit() {
  fnGitAdd
  git commit -m "$1"
}

fnGitCommitPush() {
  if (( $# == 0 )) then
    echo "commit what sucka?!"
  else
    fnGitCommit $1
    git pull
    git push
  fi
}

fnGitMerge() {
  if (( $# == 0 )) then
    # save current branch
    original_branch=$(git branch | grep "* ");
    original_branch=${original_branch/"* "};
  
    # update master
    git checkout master
    git pull
    
    # merge into original branch
    git checkout $original_branch
    git merge master

    unset original_branch
  else
    git merge $1
  fi
}

fnGitLog() {
  if (( $# == 0 )) then
    git log --decorate --graph --oneline -n 10
  else
    git log --decorate --graph --oneline -n $1
  fi
}

fnGitLogVerbose() {
  if (( $# == 0 )) then
    git log --decorate --graph -n 10
  else
    git log --decorate --graph -n $1
  fi
}

##################################################
# Helper functions
##################################################

fnIsGitRepo() {
  git rev-parse --is-inside-work-tree
}

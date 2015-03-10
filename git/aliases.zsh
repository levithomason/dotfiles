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

  git checkout $original_branch

  fnGitBranch
  
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
  if (( $# > 0 )) then
    git checkout $*
  else
    go_counter=1
    go_branches=()
  
    # get branches, excluding current and master
    go_branches=$(git branch | grep -v "\*" | egrep -v "master")
  
    # array from lines
    go_branches=("${(f)go_branches}")
  
    for go_branch in $go_branches; do
      # replace spaces
      go_branch=${go_branch//" "}
      
      # add branch to array
      go_branches[$go_counter]=$go_branch
      
      # print array index and folder name
      echo "$go_counter: $go_branch"
  
      # increment counter
      go_counter=$((go_counter+1))
    done;
    
    echo ""
    read "go_choice?master/#: "
    
    # checkout master by default
    if [[ $go_choice == "" ]] then
      git checkout master
    else
      go_branch_name=$go_branches[$go_choice]
    
      # checkout branch if a valid array item was selected
      if [[ $go_branch_name != "" ]] then
        git checkout $go_branch_name
      else
        fnGitCheckout $1
      fi
    fi
  fi

  unset go_counter
  unset go_branches
  unset go_branch
  unset go_choice
  unset go_branch_name
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

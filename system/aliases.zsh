# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`

if $(gls &>/dev/null)
then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -l --color"
  alias la="gls -A --color"
fi

alias odot="open ~/.dotfiles"
alias "cd.."="cd .."
alias ".."="cd .."
alias ws="wstorm"
alias ren=fnRename
alias src=fnSrcProject

# Project Change Directory - Changes directory to a folder in ~/src/*
#
# Matches project folders starting with arg
# Changes to project if 1 match
# Lists projects if > 1 match
#
fnSrcProject() {
  src_counter=1
  src_projects=()

  for project in ~/src/*$1*; do
    # get folder name
    src_basename=$(basename $project)

    # add folder to array
    src_projects[$src_counter]=$src_basename

    # print array index and folder name
    echo "$src_counter: $src_basename"

    # increment counter
    src_counter=$((src_counter+1))
  done;
  
  # set project name if only 1 match
  # else, prompt for array index from above echoed list
  if (( ${#src_projects[@]} == 1 )) then
    src_project_name=$src_projects[1]
  else
    echo ""
    read "src_choice?# "
    src_project_name=$src_projects[$src_choice]
  fi
  
  # change directory if a valid array item was selected
  if [[ $src_project_name != "" ]] then
    cd ~/src/$src_project_name/
  else
    fnSrcProject $1
  fi
  
  unset src_counter
  unset src_projects
  unset src_basename
  unset src_choice
  unset src_project_name
}

# Bulk Rename - Renames all occurrences in the current directory
#
# Given:
#   foo-thing.txt
#   another-foo-item.js
#   foo/
#     last-foo.html
#
# Command:
#   ren foo bar
#
# Results:
#   bar-thing.txt
#   another-bar-item.js
#   bar/
#     last-bar.html

fnRename() {
  for a in *$1*; do
    mv $a ${a//$1/$2};
  done;
}

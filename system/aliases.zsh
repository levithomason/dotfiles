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
alias ren=fnRename
alias src="cd ~/src/"

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

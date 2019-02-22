#
# Sets up some useful commands for fzf
#
# Authors:
#	Junegunn Choi
#	Robbie Smith <zoqaeski@gmail.com>
#	(…and others)
#

# Return if requirements are not found
if (( ! $+commands[fzf] )); then
	return 1
fi

pmodload 'editor'

# Default command for fzf
# export FZF_DEFAULT_COMMAND="find -L * -path '*/\.*' -prune -o -type f -print -o -type l -print 2> /dev/null"

# FZF conveniences
# TODO Figure out a better way of including these, as the install path for fzf
# may be different for others
source "${0:h}/completion.zsh"
source "${0:h}/key-bindings.zsh"

# FZF Bookmarks
# WIP
# source "${0:h}/bookmarks.zsh"

#
# Key Bindings
#

if [[ -n "$key_info" ]]; then
	bindkey "$key_info[Control]T" fzf-file-widget
	bindkey "$key_info[Control]R" fzf-history-widget
	# bindkey "$key_info[Control]G" fzf-bookmark-jump
	# bindkey "$key_info[Control]X$key_info[Control]M" fzf-bookmark
fi

#
# Useful aliases
# These were all taken from the wiki, though some were slightly modified
# https://github.com/junegunn/fzf/wiki/Examples
#

# Modified version where you can press
#   - CTRL-O to open with `open` command, which gives a list of default
#   applications
#   - Return to open with the default system application
#   - TODO figure out how to add an editor?
fo() {
  local out file key
  IFS=$'\n' out=($(fzf-tmux --query="$1" --exit-0 -m --expect=ctrl-o))
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || o "$file"
  fi
}

# cdf - cd into the directory of the selected file
cdf() {
   local file
   local dir
   file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir"
}

# fdr - cd to selected parent directory
fdr() {
  local declare dirs=()
  get_parent_dirs() {
    if [[ -d "${1}" ]]; then dirs+=("$1"); else return; fi
    if [[ "${1}" == '/' ]]; then
      for _dir in "${dirs[@]}"; do echo $_dir; done
    else
      get_parent_dirs $(dirname "$1")
    fi
  }
  local DIR=$(get_parent_dirs $(realpath "${1:-$(pwd)}") | fzf --tac)
  cd "$DIR"
}

# fh - repeat history
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

if (( $+commands[fasd] )); then
  # fcd - fasd change directory: cd into MRU dirs from fasd
  fcd() {
    local dir
    dir=$(fasd -dlR | fzf +m --no-sort) && cd "$dir"
  }  

  alias j='fcd' 
fi



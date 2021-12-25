#
# Defines tmux aliases and provides for auto launching it at start-up.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#   Colin Hebert <hebert.colin@gmail.com>
#   Georges Discry <georges@discry.be>
#   Xavier Cambar <xcambar@gmail.com>
#

# Return if requirements are not found.
if (( ! $+commands[tmux] )); then
  return 1
fi

# iTerm integration
if ([[ "$TERM_PROGRAM" = 'iTerm.app' ]] && \
  zstyle -t ':prezto:module:tmux:iterm' integrate \
); then
  _tmux_iterm_integration='-CC'
fi

#
# Functions
#
local _session_name
local _session_path

local not_in_tmux() {
  [[ -z "$TMUX" && -z "$EMACS" && -z "$VIM" && -z "$INSIDE_EMACS" && "$TERM_PROGRAM" != "vscode" ]]
}

tmux_has_session() {
  tmux has-session -t "$1" 2> /dev/null
}

tmux_create_detached() {
  local _start_dir=$1
  if [[ -d "${_start_dir}" ]] ; then
    _session_path="${_start_dir}"
  else
    _session_path="${PWD}"
  fi
  _session_name=${$(basename "${_session_path}" | tr . -)//./_}
  if ! tmux_has_session "${_session_name}" ; then
    tmux new-session -d -s "${_session_name}" -c "${_session_path}"
  fi
}

tmux_switch() {
  local _arg=$1
  if [[ -n "$_arg" ]] && tmux_has_session "$_arg"; then
    _session_name="$_arg"
  else
      tmux_create_detached "$_arg"
  fi
  if not_in_tmux; then
    tmux $_tmux_iterm_integration attach-session -d -t "${_session_name}"
  else
    tmux switch-client -t "${_session_name}"
  fi
}

#
# Auto Start
#


if not_in_tmux && ( \
  ( [[ -n "$SSH_TTY" ]] && zstyle -t ':prezto:module:tmux:auto-start' remote ) ||
  ( [[ -z "$SSH_TTY" ]] && zstyle -t ':prezto:module:tmux:auto-start' local ) \
); then
  tmux start-server

  # Create a 'prezto' session if no session has been defined in tmux.conf.
  zstyle -s ':prezto:module:tmux:session' name tmux_session || tmux_session='prezto'
  if ! tmux_has_session "$tmux_session"; then
    tmux \
      new-session -d -s "$tmux_session" \; \
      set-option -t "$tmux_session" destroy-unattached off &> /dev/null
  fi

  # Attach to the 'prezto' session if it isn't currently active, otherwise start a new session
  if [[ $(tmux ls -F "#{session_name}: #{?session_attached,attached,not attached}" | grep "$tmux_session: not attached") ]]; then
    exec tmux $_tmux_iterm_integration attach -t "$tmux_session"
  else
    exec tmux $_tmux_iterm_integration new-session -c "$PWD"
  fi
fi

#
# Aliases
#

alias tmuxc=tmux_create_detached
alias tmuxs=tmux_switch
alias tmuxa="tmux $_tmux_iterm_integration new-session -A"
alias tmuxl='tmux list-sessions'

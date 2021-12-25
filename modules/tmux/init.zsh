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

#
# Auto Start
#

if ([[ "$TERM_PROGRAM" = 'iTerm.app' ]] && \
  zstyle -t ':prezto:module:tmux:iterm' integrate \
); then
  _tmux_iterm_integration='-CC'
fi

if [[ -z "$TMUX" && -z "$EMACS" && -z "$VIM" && -z "$INSIDE_EMACS" && "$TERM_PROGRAM" != "vscode" ]] && ( \
  ( [[ -n "$SSH_TTY" ]] && zstyle -t ':prezto:module:tmux:auto-start' remote ) ||
  ( [[ -z "$SSH_TTY" ]] && zstyle -t ':prezto:module:tmux:auto-start' local ) \
); then
  tmux start-server

  # Create a 'prezto' session if no session has been defined in tmux.conf.
  zstyle -s ':prezto:module:tmux:session' name tmux_session || tmux_session='prezto'
  if ! tmux has-session 2> /dev/null; then
    tmux \
      new-session -d -s "$tmux_session" \; \
      set-option -t "$tmux_session" destroy-unattached off &> /dev/null
  fi

  # Attach to the 'prezto' session if it isn't currently active, otherwise start a new session
  if ! [[ $(tmux ls -F "#{session_name}: #{?session_attached,attached,not attached}" | grep "$tmux_session: attached") ]]; then
    exec tmux attach -t "$tmux_session"
  else
    exec tmux $_tmux_iterm_integration new-session -c "$PWD"
  fi
fi

#
# Functions
#

#
# Aliases
#

# alias tmuxa="tmux $_tmux_iterm_integration new-session -A"
# alias tmuxl='tmux list-sessions'

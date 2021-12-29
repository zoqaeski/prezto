#
# Provides for an easier use of SSH by setting up ssh-agent using keychain.
#
# Authors:
#   Robbie Smith <zoqaeski@gmail.com>
#

# Return if requirements are not found.
if (( ! $+commands[keychain] )); then
  return 1
fi

# Set the path to the SSH directory.
_ssh_dir="$HOME/.ssh"

zstyle -a ':prezto:module:ssh:load' identities '_ssh_identities'

eval $(keychain --eval --quiet --agents ssh,gpg ${_ssh_identities:+$_ssh_dir/${^_ssh_identities[@]}})

unset _ssh_{dir,identities}

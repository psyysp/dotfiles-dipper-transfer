# Corrected .bashrc without cursor change in vi mode

# Set PATH
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Customize PS1
if [ $(id -u) -eq 0 ]; then
    PS1='\[\e[31m\]\u\[\e[0m\]@'
else
    PS1='\[\e[32m\]\u\[\e[0m\]@'
fi
PS1+='\[\e[32m\]$(hostname | sed "s/<redacted>-//" | sed "s/\.local//")\[\e[0m\]:'
PS1+='\[\e[32m\]bash\[\e[0m\]'
PS1+='\[\e[33m\]$(pwd)\[\e[0m\] % '

# Turn off the bell
set bell-style none

# mapping ctrl + L to clear
bind -x '"\C-l": clear'

# Bash completion setup
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# function git_branch_4_ps1 {     # get git branch of pwd
#         local branch="$(git branch 2>/dev/null | grep "\*" | colrm 1 2)"
#         if [ -n "$branch" ]; then
#             echo "(git: $branch)"
#         fi
#     }

# Git prompt (simplified)
# git_branch() {
#   branch=$(git branch 2>/dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p')
#   if [ -n "$branch" ]; then
#     echo " ($branch)"
#   fi
# }
# PS1+='$(git_branch)'

# vi mode
set -o vi

# nvm setup
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm

# Export additional paths
export JFLEX_DIR=$HOME/jflex-1.7.0
export CUP_DIR=$HOME/cup

# rbenv initialization
if command -v rbenv >/dev/null; then eval "$(rbenv init -)"; fi

bash -c 'source ~.bashrc'
. "$HOME/.cargo/env"

. "$HOME/.local/bin/env"

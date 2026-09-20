# Edit this file: ~/.config/zsh/.zshrc
# ~/.zshrc is a symlink here. Dotdipper tracks this path (copy mode), not compiled/.
# Fast vanilla zsh. No Oh My Zsh.
# Order matters: options → PATH (no forks) → completion once → keys → prompt → tools → plugins last.

# --- options / history -------------------------------------------------------
# /etc/zshrc sets HISTSIZE=2000 SAVEHIST=1000 BEEP. Override those here.
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY HIST_REDUCE_BLANKS HIST_VERIFY
setopt EXTENDED_GLOB PROMPT_SUBST INTERACTIVE_COMMENTS
unsetopt BEEP LIST_BEEP
typeset -U path PATH fpath

export KEYTIMEOUT=1
export EDITOR=${EDITOR:-vim}
export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

# --- PATH (no `brew --prefix`, no eval of slow inits) ------------------------
path=(
  "$HOME/.local/bin"
  "$HOME/.antigravity/antigravity/bin"
  $path
)
# Drop leftover nvm/rbenv bins from parent shells that sourced the old rc.
path=(${path:#$HOME/.nvm/versions/node/*/bin})
path=(${path:#$HOME/.rbenv/shims})

# mise: shims on PATH, no hook-env. Full `eval "$(mise activate zsh)"` spawns
# `mise hook-env` at startup and again on every prompt (~30ms). Shims resolve
# node/ruby (and .nvmrc / .ruby-version) when you run the tool instead.
# Do not also put nvm/rbenv shims on PATH — they would fight mise.
path=("$HOME/.local/share/mise/shims" $path)

# Old nvm/rbenv PATH setup (replaced by mise). Uncomment only if you drop mise.
# export NVM_DIR="$HOME/.nvm"
# nvm() {
#   unset -f nvm
#   source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
#   nvm "$@"
# }
# [[ -d $HOME/.rbenv/shims ]] && path=("$HOME/.rbenv/shims" $path)

export JFLEX_DIR=$HOME/jflex-1.7.0
export CUP_DIR=$HOME/cup

# --- completion (exactly once; skip fpath scan when dump is fresh) -----------
autoload -Uz compinit add-zsh-hook
zmodload zsh/complist
zstyle ':completion:*' menu select
_compdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ ! -s $_compdump || -n $_compdump(#qN.mh+24) ]]; then
  compinit -d $_compdump
  [[ -s $_compdump && (! -s ${_compdump}.zwc || $_compdump -nt ${_compdump}.zwc) ]] &&
    zcompile $_compdump
else
  compinit -C -d $_compdump
fi
_comp_options+=(globdots)
unset _compdump

# --- vi mode + cursor --------------------------------------------------------
bindkey -v
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = block ]]; then
    echo -ne '\e[2 q'
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} == '' ]] || [[ $1 = beam ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

function zle-line-init {
  [[ -o zle ]] && zle -K viins
  echo -ne '\e[5 q'
}
zle -N zle-line-init

_fix_cursor() { echo -ne '\e[5 q' }
add-zsh-hook precmd _fix_cursor

# --- prompt ------------------------------------------------------------------
# user@host~/path (git) %#
# gitstatusd (already installed) is the fast way to get Starship-like git info
# without replacing this prompt. Do not source gitstatus.prompt.zsh — it overwrites PROMPT.
PROMPT="%(!.%F{red}.%F{green})%n%f"
PROMPT+="@"
PROMPT+="%F{green}${${(%):-%m}#<redacted>-}%f"
PROMPT+="%F{yellow}%d%f"
PROMPT+='${GITSTATUS_PROMPT}'
PROMPT+=" %# "

_gitstatus_apply() {
  emulate -L zsh
  typeset -g GITSTATUS_PROMPT=
  [[ $VCS_STATUS_RESULT == ok-* ]] || return

  local p=' %F{034}('
  if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
    p+=${VCS_STATUS_LOCAL_BRANCH//\%/%%}
  elif [[ -n $VCS_STATUS_TAG ]]; then
    p+="#${VCS_STATUS_TAG//\%/%%}"
  else
    p+="@${VCS_STATUS_COMMIT[1,8]}"
  fi
  p+=')%f'

  (( VCS_STATUS_COMMITS_BEHIND )) && p+=" %F{cyan}⇣${VCS_STATUS_COMMITS_BEHIND}%f"
  (( VCS_STATUS_COMMITS_AHEAD  )) && p+=" %F{cyan}⇡${VCS_STATUS_COMMITS_AHEAD}%f"
  (( VCS_STATUS_STASHES        )) && p+=" %F{cyan}*${VCS_STATUS_STASHES}%f"
  [[ -n $VCS_STATUS_ACTION     ]] && p+=" %F{red}${VCS_STATUS_ACTION}%f"
  (( VCS_STATUS_NUM_CONFLICTED )) && p+=" %F{red}~${VCS_STATUS_NUM_CONFLICTED}%f"
  (( VCS_STATUS_NUM_STAGED     )) && p+=" %F{yellow}+${VCS_STATUS_NUM_STAGED}%f"
  (( VCS_STATUS_NUM_UNSTAGED   )) && p+=" %F{yellow}!${VCS_STATUS_NUM_UNSTAGED}%f"
  (( VCS_STATUS_NUM_UNTRACKED  )) && p+=" %F{blue}?${VCS_STATUS_NUM_UNTRACKED}%f"

  GITSTATUS_PROMPT=$p
}

_gitstatus_precmd() {
  gitstatus_query -t 0.1 MY 2>/dev/null || return
  _gitstatus_apply
}

_gitstatus_plugin="$HOMEBREW_PREFIX/opt/gitstatus/gitstatus.plugin.zsh"
if [[ -r $_gitstatus_plugin ]] && source $_gitstatus_plugin &&
   gitstatus_start -t 1 -s -1 -u -1 -c -1 -d -1 -m 16384 MY 2>/dev/null; then
  # -m 16384: skip dirty-file counts in huge indexes so the prompt stays snappy.
  add-zsh-hook precmd _gitstatus_precmd
else
  # Fallback: branch name only. Do not enable check-for-changes (walks the tree).
  autoload -Uz vcs_info
  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:git:*' formats ' %F{034}(%b)%f'
  zstyle ':vcs_info:git:*' actionformats ' %F{034}(%b)%f %F{red}%a%f'
  add-zsh-hook precmd vcs_info
  PROMPT="%(!.%F{red}.%F{green})%n%f"
  PROMPT+="@"
  PROMPT+="%F{green}${${(%):-%m}#<redacted>-}%f"
  PROMPT+="%F{yellow}%d%f"
  PROMPT+=\$vcs_info_msg_0_
  PROMPT+=" %# "
fi
unset _gitstatus_plugin

# Starship is a full prompt replacement (cross-shell, TOML). Uncomment to use it
# instead of the block above — do not run both.
# eval "$(starship init zsh)"

# --- tools -------------------------------------------------------------------
# z stays `z`. Do not pass --cmd cd.
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# Ctrl-R fuzzy history, Ctrl-T files, Alt-C dirs. After bindkey -v.
(( $+commands[fzf] )) && source <(fzf --zsh)

# --- commented aliases (intentionally off) -----------------------------------
# brew install eza   # not currently installed
# alias ls='eza --group-directories-first'
# alias ll='eza -l --git --group-directories-first'
# alias la='eza -la --git --group-directories-first'
# alias lt='eza --tree --level=2'
# alias cat='bat --paging=never'
# alias grep='rg'
# alias find='fd'
# alias ..='cd ..'
# alias ...='cd ../..'

# --- plugins (syntax-highlighting must be last) ------------------------------
_zsh_autosuggestions="$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -r $_zsh_autosuggestions ]] || _zsh_autosuggestions=$HOME/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r $_zsh_autosuggestions ]] && source $_zsh_autosuggestions
unset _zsh_autosuggestions

_zsh_syntax="$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ -r $_zsh_syntax ]] || _zsh_syntax=$HOME/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -r $_zsh_syntax ]] && source $_zsh_syntax
unset _zsh_syntax

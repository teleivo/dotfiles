#!/usr/bin/env zsh
# uncomment the next line to profile zsh startup
# zmodload zsh/zprof

# TODO move my plugins in a plugins folder?
# fpath=($DOTFILES/zsh/plugins $fpath)

# navigation
setopt auto_cd
setopt auto_pushd
setopt correct
setopt extended_glob
setopt pushd_ignore_dups
setopt pushd_silent
setopt pushdminus

# quickly move between directories on stack
function d() {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}

# history
setopt append_history            # append to history file
setopt extended_history          # write the history file in the ':start:elapsed;command' format
setopt hist_expire_dups_first    # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_find_no_dups         # do not display a previously found event
setopt hist_ignore_all_dups      # delete an old recorded event if a new event is a duplicate
setopt hist_ignore_dups          # do not record an event that was just recorded again
setopt hist_ignore_space         # do not record an event starting with a space
setopt hist_no_store             # don't store history commands
setopt hist_save_no_dups         # do not write a duplicate event to the history file
setopt hist_verify               # show command with history expansion to user before running it
setopt inc_append_history        # write to the history file immediately, not when the shell exits
setopt share_history             # share history between all sessions

# include lbuffer when using arrow keys to cycle through the history
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "$terminfo[kcuu1]" history-beginning-search-backward-end # up arrow
bindkey "$terminfo[kcud1]" history-beginning-search-forward-end # down arrow

# prompt
autoload -Uz add-zsh-hook vcs_info
add-zsh-hook precmd vcs_info

function k8s_context() {
  local context
  context=$(kubectl config view --output 'jsonpath={..namespace}' 2>/dev/null)
  if [[ -n "$context" ]]; then
    echo " ($context)"
  fi
}

fpath=($DOTFILES/zsh $fpath)
setopt prompt_subst
autoload -Uz prompt_setup; prompt_setup
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats '%u%c %b'
# format when the repo is in an action (merge, rebase, etc)
zstyle ':vcs_info:git*' actionformats '%u%c %B%a%%b %b'
zstyle ':vcs_info:*:*'  check-for-changes true
zstyle ':vcs_info:git*' unstagedstr '*'
zstyle ':vcs_info:git*' stagedstr '+'

# completion
zmodload zsh/complist
autoload -U compinit; compinit
setopt menu_complete        # automatically highlight first element of completion menu
setopt auto_list            # automatically list choices on ambiguous completion
setopt complete_in_word     # complete from both ends of a word

# show colors in completion menu
zstyle ':completion:*' menu select
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# close and undo completion menu on esc
bindkey -M menuselect '^[' undo

compdef _dirs d

source <(kubectl completion zsh)
# Configure https://github.com/junegunn/fzf
# key bindings and fuzzy completion
source <(fzf --zsh)

# vi config
source "$DOTFILES/zsh/plugins/cursor-mode.zsh"
source "$DOTFILES/zsh/plugins/vim-mode.zsh"

[[ -r ${HOME}/.alias ]]; source ${HOME}/.alias

[[ -r ~/.fzf.zsh ]] && source ~/.fzf.zsh
[[ -r ~/.fzf-git/fzf-git.sh ]] && source ~/.fzf-git/fzf-git.sh
[[ -r ~/.fzf-scripts/docker.zsh ]] && source ~/.fzf-scripts/docker.zsh
[[ -r ~/.fzf-scripts/kubernetes.zsh ]] && source ~/.fzf-scripts/kubernetes.zsh

# Override fzf-git look
_fzf_git_fzf() {
  fzf --height=50% --tmux 90%,70% \
    --multi --min-height=20 \
    --preview-window='right,50%,border-left' \
    --bind='ctrl-/:change-preview-window(down,50%,border-top|hidden|)' "$@"
}

# Get all git branches expect the current one. Useful for switching, deleting, ... branches.
fzf_git_branches_without_current() {
  # assumes the current branch is prefixed with '*'
  _fzf_git_check || return
  git branch --color=always --sort=-committerdate --sort=-HEAD --format=$'%(HEAD) %(color:yellow)%(refname:short) %(color:green)(%(committerdate:relative))\t%(color:blue)%(subject)%(color:reset)' | grep --invert-match '^*' |
  _fzf_git_fzf --ansi \
    --border-label '🌲 Branches' \
    --header-lines 0 \
    --tiebreak begin \
    --preview-window down,border-top,40% \
    --no-hscroll \
    --bind 'ctrl-/:change-preview-window(down,70%|hidden|)' \
    --bind "ctrl-o:execute-silent:bash $__fzf_git branch {}" \
    --bind "alt-a:change-border-label(🌳 All branches)+reload:bash \"$__fzf_git\" all-branches" \
    --preview "git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' \$(sed s/^..// <<< {} | cut -d' ' -f1) --" "$@" |
  sed 's/^..//' | cut -d' ' -f1
}

# Checkout another git branch
gco() {
  if [ $# -eq 0 ]; then # only open fzf when no args given
    fzf_git_branches_without_current --no-multi | xargs --no-run-if-empty git checkout
  else
    git checkout $@
  fi
}

# Delete git branches
gbDelete() {
  if [ $# -eq 0 ]; then # only open fzf when no args given
    fzf_git_branches_without_current | xargs --no-run-if-empty git branch --delete --force
  else
    git branch --delete --force $@
  fi
}

# Interactive git rebase
grbi() {
  if [ $# -eq 0 ]; then # only open fzf when no args given
    _fzf_git_hashes --no-multi | xargs --no-run-if-empty git rebase --interactive
  else
    git rebase --interactive
  fi
}

# https://github.com/alacritty/alacritty/blob/master/INSTALL.md#shell-completions
fpath+=${ZDOTDIR:-~}/.zsh_functions

eval "$(direnv hook zsh)"
eval "$(atuin init zsh --disable-up-arrow)"
export _ZO_DATA_DIR="$HOME/Documents/.zoxide"
eval "$(zoxide init --cmd j zsh)"

# uncomment the next line to profile zsh startup
# zprof

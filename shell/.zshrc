# uncomment the next line to profile zsh startup
# zmodload zsh/zprof

# zsh config
export ZSH=$HOME/.oh-my-zsh
export DISABLE_AUTO_UPDATE=true
ZSH_THEME="teleivo"

# User configuration
export LC_ALL=en_US.UTF-8
export GEM_HOME=$HOME/.gem
export GOROOT=$($HOME/go/bin/go1.23.1 env GOROOT)
export PATH="$HOME/bin:/usr/local/bin:/usr/local/sbin:$HOME/.local/bin:$GOROOT/bin:$HOME/go/bin:$HOME/.gem/bin/:/snap/bin:$HOME/.cargo/bin:$(yarn global bin):$HOME/.local/mvnd/bin:/opt/visualvm/bin:$PATH"
export JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64
export DHIS2_HOME=$HOME/.local/dhis2
export MAVEN_OPTS="-Dorg.slf4j.simpleLogger.showThreadName=true -Dorg.slf4j.simpleLogger.showDateTime=true -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss,SSS"
export RIPGREP_CONFIG_PATH=$HOME/.config/rg/ripgreprc

source $ZSH/oh-my-zsh.sh

# Function d masks my docker script
unset -f d

export EDITOR='vim'

# important for GPG to work properly
export GPG_TTY=$(tty)

# use gnu time instead
disable -r time
export TIME="\t%e real,\t%U user,\t%S sys, %w ctx-switch"

# Show domain since left prompt only shows hostname
# maybe find a way to show fqdn on the left
#export RPROMPT=$(hostname -d)

if [ -f ${HOME}/.alias ]; then
    source ${HOME}/.alias
fi

if [ -f ${HOME}/.load_ssh_agent ]; then
    source ${HOME}/.load_ssh_agent
fi

# Configure https://github.com/junegunn/fzf
# key bindings and fuzzy completion
source <(fzf --zsh)
# color theme from https://github.com/junegunn/fzf/blob/master/ADVANCED.md#generating-fzf-color-theme-from-vim-color-schemes
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border --cycle --info=right --no-separator
--color=fg:#9ea3c0,fg+:#9ea3c0,bg:#222433,bg+:#2a2c3f,hl:#545c8c,hl+:#929be5:underline
--color=border:#9ea3c0,spinner:#929be5,header:#545c8c,info:#929be5,pointer:#ff79c6,marker:#ac8b83,prompt:#929be5'
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.fzf-git/fzf-git.sh ] && source ~/.fzf-git/fzf-git.sh

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

source <(kubectl completion zsh)
# https://github.com/alacritty/alacritty/blob/master/INSTALL.md#shell-completions
fpath+=${ZDOTDIR:-~}/.zsh_functions

# use maven daemon instead of plain maven
alias mvn=mvnd
eval "$(direnv hook zsh)"
eval "$(atuin init zsh --disable-up-arrow)"
export _ZO_DATA_DIR="$HOME/Documents/.zoxide"
eval "$(zoxide init --cmd j zsh)"

# uncomment the next line to profile zsh startup
# zprof

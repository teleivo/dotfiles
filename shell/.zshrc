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
# color theme from https://github.com/wadackel/vim-dogrun#fzf
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border
--cycle
--color=fg:#8085a6,bg:#222433,hl:#bdc3e6
--color=fg+:#8085a6,bg+:#363e7f,hl+:#bdc3e6
--color=info:#929be5,prompt:#545c8c,pointer:#ff79c6
--color=marker:#b871b8,spinner:#73c1a9,header:#545c8c,border:#545c8c,gutter:-1'
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.fzf-git/fzf-git.sh ] && source ~/.fzf-git/fzf-git.sh

# TODO handle - to switch back
gco() {
  _fzf_git_branches --no-multi | xargs --no-run-if-empty git checkout
}

gbDelete() {
  _fzf_git_branches --no-multi | xargs --no-run-if-empty git branch -D
}

grbi() {
  _fzf_git_hashes --no-multi | xargs --no-run-if-empty git rebase -i
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

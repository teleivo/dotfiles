# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
plugins=(mvn)

# User configuration

export GOPATH=$HOME/code/go
export GEM_HOME=$HOME/.gem
export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$GOPATH/bin:$HOME/.gem/bin/:$PATH
export LC_ALL=en_US.UTF-8

source $ZSH/oh-my-zsh.sh

export EDITOR='vim'

# important for GPG to work properly
export GPG_TTY=$(tty)

# Show domain since left prompt only shows hostname
# maybe find a way to show fqdn on the left
#export RPROMPT=$(hostname -d)

if [ -f ${HOME}/.alias ]; then
    source ${HOME}/.alias
fi
alias date=gdate

if [ -f ${HOME}/.load_ssh_agent ]; then
    source ${HOME}/.load_ssh_agent
fi

if [ -f ${HOME}/.load_paths ]; then
    source ${HOME}/.load_paths
fi
export PATH="/usr/local/opt/node@10/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# Configure https://github.com/junegunn/fzf
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

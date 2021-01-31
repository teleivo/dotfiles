# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
plugins=(mvn zsh-syntax-highlighting)

# User configuration

export GOPATH=$HOME/code/go
export GEM_HOME=$HOME/.gem
export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$GOPATH/bin:$HOME/.gem/bin/:/snap/bin:$PATH
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

if [ -f ${HOME}/.load_ssh_agent ]; then
    source ${HOME}/.load_ssh_agent
fi

if [ -f ${HOME}/.load_paths ]; then
    source ${HOME}/.load_paths
fi

# Configure https://github.com/junegunn/fzf
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

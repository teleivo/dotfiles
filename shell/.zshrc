# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="teleivo"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
plugins=(mvn fzf)

# User configuration

export GEM_HOME=$HOME/.gem
export PATH="$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/local/go/bin:$HOME/go/bin:$HOME/.gem/bin/:/snap/bin:$HOME/.cargo/bin:$(yarn global bin):/opt/visualvm/bin:$PATH"
export LC_ALL=en_US.UTF-8
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export DHIS2_HOME=$HOME/.local/dhis2
export MAVEN_OPTS="-Dorg.slf4j.simpleLogger.showThreadName=true -Dorg.slf4j.simpleLogger.showDateTime=true -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss,SSS"

source $ZSH/oh-my-zsh.sh

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
# color theme from https://github.com/wadackel/vim-dogrun/issues/11
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border
--color=fg:#9ea3c0,bg:#222433,hl:#545c8c
--color=fg+:#535f98,bg+:#2a2c3f,hl+:#929be5
--color=info:#545c8c,prompt:#929be5,pointer:#73c1a9
--color=marker:#73c1a9,spinner:#b5ae7d,header:#87afaf'
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow'
source /usr/share/autojump/autojump.sh
j() {
    if [[ "$#" -ne 0 ]]; then
        cd $(autojump $@)
        return
    fi
    cd "$(autojump -s | sort -k1gr | awk '$1 ~ /[0-9]:/ && $2 ~ /^\// { for (i=2; i<=NF; i++) { print $(i) } }' |  fzf --height 40% --reverse --inline-info)"
}
# https://github.com/alacritty/alacritty/blob/master/INSTALL.md#shell-completions
fpath+=${ZDOTDIR:-~}/.zsh_functions

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

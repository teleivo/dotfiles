# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="teleivo"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
plugins=(mvn fzf tmux)

# User configuration

export GEM_HOME=$HOME/.gem
export GOROOT=$($HOME/go/bin/go1.21.1 env GOROOT)
export PATH="$HOME/bin:/usr/local/bin:/usr/local/sbin:$HOME/.local/bin:$GOROOT/bin:$HOME/go/bin:$HOME/.gem/bin/:/snap/bin:$HOME/.cargo/bin:$(yarn global bin):/opt/visualvm/bin:$PATH"
export LC_ALL=en_US.UTF-8
export JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64
export DHIS2_HOME=$HOME/.local/dhis2
export MAVEN_OPTS="-Dorg.slf4j.simpleLogger.showThreadName=true -Dorg.slf4j.simpleLogger.showDateTime=true -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss,SSS"
export ZSH_TMUX_AUTOSTART=true

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
# color theme from https://github.com/wadackel/vim-dogrun#fzf
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border
--cycle
--color=fg:#8085a6,bg:#222433,hl:#bdc3e6
--color=fg+:#8085a6,bg+:#363e7f,hl+:#bdc3e6
--color=info:#929be5,prompt:#545c8c,pointer:#ff79c6
--color=marker:#b871b8,spinner:#73c1a9,header:#545c8c,border:#545c8c,gutter:-1'
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow'
source /usr/share/autojump/autojump.sh
j() {
    if [[ "$#" -ne 0 ]]; then
        cd $(autojump $@)
        return
    fi
    cd "$(autojump -s | sort -k1gr | awk '$1 ~ /[0-9]:/ && $2 ~ /^\// { for (i=2; i<=NF; i++) { print $(i) } }' |  fzf --height 40% --reverse --inline-info)"
}
source <(kubectl completion zsh)
# https://github.com/alacritty/alacritty/blob/master/INSTALL.md#shell-completions
fpath+=${ZDOTDIR:-~}/.zsh_functions

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
# use maven daemon instead of plain maven
alias mvn=mvnd
eval "$(direnv hook zsh)"

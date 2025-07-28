#!/usr/bin/env zsh
# .zshenv is symlinked into $HOME while other zsh configs are taken from ZDOTDIR

export LC_ALL=en_US.UTF-8

export EDITOR="nvim"
export VISUAL="nvim"
# vim-mode should not set the prompt
export MODE_INDICATOR=""

export DOTFILES=$HOME/code/dotfiles

export GOROOT=/home/ivo/sdk/go1.24.4
export JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64
export DHIS2_HOME=$HOME/.local/dhis2
export MAVEN_OPTS="-Dorg.slf4j.simpleLogger.showThreadName=true -Dorg.slf4j.simpleLogger.showDateTime=true -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss,SSS"
export RIPGREP_CONFIG_PATH=$HOME/.config/rg/ripgreprc

export XDG_DATA_DIRS="/usr/share:/usr/local/share:$HOME/.local/share"

# important for GPG to work properly
export GPG_TTY=$(tty)

# use gnu time instead
disable -r time
export TIME="\t%e real,\t%U user,\t%S sys, %w ctx-switch"

# zsh
export ZDOTDIR="$DOTFILES/zsh"
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=10000

export MANPAGER='nvim +Man!'

# fzf
# color config based on vim-dogrun that I try to keep in sync with the telescope.nvim color
# config ../vim/.config/nvim/lua/plugins/colorscheme.lua
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border --cycle --info=inline-right --no-separator
--bind "ctrl-d:preview-down" --bind "ctrl-u:preview-up"
--bind "ctrl-f:page-down" --bind "ctrl-b:page-up"
--bind "ctrl-/:toggle-preview"
--color=fg:#9ea3c0,fg+:#9ea3c0,bg:#222433,gutter:#2a2c3f,bg+:#363e7f,hl:#545c8c:underline,hl+:#929be5:underline
--color=border:#545c8c,spinner:#ff79c6,header:#545c8c,label:#929be5,info:#929be5,pointer:#b871b8,marker:#7cbe8c,prompt:#929be5'
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow'
# apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# add only new items to path
typeset -U path
yarn_bin="$(yarn global bin)"
path=(~/bin ~/.local/bin $GOROOT/bin ~/go/bin ~/.cargo/bin ~/.local/mvnd/bin /opt/visualvm/bin $yarn_bin ~/code/learning/cs143/bin ~/.luarocks/bin $path)

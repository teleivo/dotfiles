#!/bin/zsh
# Fuzzy searchable docker container control pane using https://github.com/junegunn/fzf.
# Find docker containers to follow their logs, stop, debug them or copy their name or a port.
#
# Parts of this script are modified versions of https://github.com/junegunn/fzf-git.sh which is
# licensed under https://github.com/junegunn/fzf-git.sh/blob/6a5d4a923b86908abd9545c8646ae5dd44dff607/fzf-git.sh#L1-L21
#
# # The MIT License (MIT)
#
# Copyright (c) 2024 Junegunn Choi
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

__d=$0:A

# TODO is there a way to reload using the last command? does fzf keep track of that somehow? --bind "ctrl-r:reload:zsh $__d containers" \
# TODO nice to have: keep a tmux popup border around the fzf execute actions to distinguish the
# popup text from the background

# List Docker ports
_fzf_docker_ports() {
  # TODO can I select the socket using an alternative binding? This adds {3} so it does not yet
  #  / ALT-S (select exposed socket)
  # interpolate and it also still puts the current item
  # --bind "alt-s:print(echo -n {3} | tr --delete '\n')+accept" |
  # TODO nice to have: can I remember to navigate to selecting a port if this is opened without an
  # arg? So make it a limited container search instead of using _fzf_docker_list
  if [ $# -eq 1 ]; then
    name=$1
    fzf \
        --tmux center,50% \
        --border-label "Docker ports for $name 🐋" \
        --header 'CTRL-Y (copy exposed port) / ALT-Y (copy exposed socket)' --header-lines=0 \
        --bind "start:reload:docker port $name" \
        --bind "ctrl-y:execute-silent(echo -n {3} | cut --delimiter=':' --fields=2 | tr --delete '\n' | xsel --clipboard)+abort" \
        --bind "alt-y:execute-silent(echo -n {3} | tr --delete '\n' | xsel --clipboard)+abort" |
        cut --delimiter=' ' --fields=3 | cut --delimiter=':' --fields=2 | tr --delete '\n'
    return
  fi

  # select container first
  _fzf_docker_list
}

# List Docker containers
_fzf_docker_list() {
  # TODO fix the command generation/interpolation to show all containers
  fzf \
      --tmux center,90% \
      --border-label 'Docker containers (running) 🐋' \
      --header 'CTRL-R (reload) / CTRL-Y (copy) / ALT-P (port) / ALT-E (exec) / ALT-L (logs) / ALT-S (stop)' --header-lines=1 \
      --bind "start:reload:zsh $__d containers" \
      --bind "ctrl-t:transform:zsh [[ ! $FZF_BORDER_LABEL =~ all ]] &&
          echo \"change-border-label(Docker containers (all) 🐋)+reload(zsh $__d all-containers)\" ||
          echo \"change-border-label(Docker containers (running) 🐋)+reload(zsh $__d containers)\"" \
      --bind 'ctrl-y:execute-silent(echo -n {1} | xsel --clipboard)+abort' \
      --bind 'alt-s:execute-silent(docker stop {1})' \
      --bind 'alt-e:execute(docker exec -it {1} /bin/bash)' \
      --bind 'alt-l:execute(docker logs --follow --tail=50 {1})' \
      --bind "alt-p:become(zsh $__d _fzf_docker_ports {1})" \
      --bind 'ctrl-/:toggle-preview' \
      --preview-window down,border-top,75%,follow \
      --preview 'docker logs --follow --tail=40 {1}' |
        cut --delimiter=' ' --fields=1
}

# List Docker images. Allows multi-selection to pass it to docker image rm.
_fzf_docker_images() {
  # TODO add open on Dockerhub
  # TODO why is the json LSP not starting when I read docker inspect from stdin?
  # TODO nice to have: can I disable dive if more than one image is selected?
  fzf \
      --tmux center,90% \
      --border-label 'Docker images 🐋' \
      --header 'CTRL-Y (copy) / ALT-I (inspect) / ALT-D (dive)' --header-lines=1 \
      --multi \
      --bind "start:reload:zsh $__d images" \
      --bind 'ctrl-y:execute-silent(echo -n {1} | xsel --clipboard)+abort' \
      --bind "alt-i:execute(docker inspect {1} | nvim - -c 'set filetype=json')" \
      --bind 'alt-d:execute(dive {1})' |
        cut --delimiter=' ' --fields=1
}

if [[ $# -gt 0 ]]; then
  containers() {
    docker ps "$@" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
  }
  images() {
    docker images --format "table {{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}"
  }
  case "$1" in
    all-containers)
      containers --all
      ;;
    containers)
      containers
      ;;
    images)
      images
      ;;
    ports)
      ports $1
      ;;
    _fzf_docker_ports)
      _fzf_docker_ports $2
      ;;
  esac
fi

__fzf_docker_join() {
  local item
  while read item; do
    echo -n "${(q)item} "
  done
}

# TODO find a better binding than C-a, sad I can't use C-d
__fzf_docker_init() {
  local m o
  for o in "$@"; do
    eval "fzf-docker-$o-widget() { local result=\$(_fzf_docker_$o | __fzf_docker_join); zle reset-prompt; LBUFFER+=\$result }"
    eval "zle -N fzf-docker-$o-widget"
    for m in emacs vicmd viins; do
      eval "bindkey -M $m '^a^${o[1]}' fzf-docker-$o-widget"
      eval "bindkey -M $m '^a${o[1]}' fzf-docker-$o-widget"
    done
  done
}
__fzf_docker_init list ports images

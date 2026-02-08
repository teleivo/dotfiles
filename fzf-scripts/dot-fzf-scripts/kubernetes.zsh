#!/usr/bin/env zsh
# Fuzzy searchable kubernetes container control pane using https://github.com/junegunn/fzf.
# Find kubernetes pods to follow their logs, stop, debug them or copy their name or a port.
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

__k=$0:A

select_running_pod() {
  local label=$1

  fzf \
      --tmux center,55% \
      --border-label $label \
      --header 'CTRL-R (reload)' --header-lines=1 \
      --prompt "$(__k8s_ns_refresh; echo $__k8s_ns)> " \
      --bind "start:reload:zsh $__k running_pods" \
      --bind "ctrl-r:reload:zsh $__k running_pods" |
      cut --delimiter=' ' --fields=1
}

# Widget to list Kubernetes ports of a pod. Pastes the selected port to the command line on enter.
# This is only tested with pods that have one container.
_fzf_kubernetes_ports() {
  local pod
  if [[ $# -eq 1 ]]; then
    pod=$1
  else
    pod=$(select_running_pod 'Select pod to search for ports ☸')
  fi

  if [[ -z $pod ]]; then
    return
  fi

  fzf \
      --tmux center,40% \
      --border-label "Kubernetes ports for pod $pod ☸" \
      --header 'CTRL-Y (copy)' --header-lines=1 \
      --bind "start:reload:zsh $__k ports $pod" \
      --bind 'ctrl-y:execute-silent(echo -n {1} | xsel --clipboard)+abort' |
      cut --delimiter=' ' --fields=1
}

# Widget to port forward to a Kubernetes pod.
_fzf_kubernetes_forward() {
  local pod
  if [[ $# -eq 1 ]]; then
    pod=$1
  else
    pod=$(select_running_pod 'Select pod for port-forwarding ☸')
  fi

  if [[ -z $pod ]]; then
    return
  fi

  local port=$(fzf \
      --tmux center,40% \
      --border-label "Forward port to Kubernetes $pod ☸" \
      --header-lines=1 \
      --bind "start:reload:zsh $__k ports $pod" |
      cut --delimiter=' ' --fields=1)

  if [[ -z $port ]]; then
    return
  fi

  zle reset-prompt
  BUFFER="kubectl port-forward $pod $port:$port"
  zle end-of-line
}

# Widget to list Kubernetes namespaces. Pastes the selected namespace to the command line on enter.
_fzf_kubernetes_namespaces() {
  fzf \
      --tmux center,40% \
      --border-label 'Kubernetes namespaces ☸' \
      --header 'CTRL-R (reload) / CTRL-Y (copy) / ALT-C (set current)' --header-lines=1 \
      --bind "start:reload:zsh $__k namespaces" \
      --bind "ctrl-r:reload:zsh $__k namespaces" \
      --bind 'ctrl-y:execute-silent(echo -n {1} | xsel --clipboard)+abort' \
      --bind 'alt-c:execute(kubectl config set-context --current --namespace={1})+abort' |
        cut --delimiter=' ' --fields=1
}

# Widget to list Kubernetes pods. Pastes the selected pod to the command line on enter.
_fzf_kubernetes_list() {
  # TODO feature: use debug pod
  fzf \
      --tmux center,90% \
      --border-label 'Kubernetes pods ☸' \
      --header 'CTRL-R (reload) / CTRL-Y (copy) / ALT-E (exec) / ALT-L (logs) / ALT-P (port)' --header-lines=1 \
      --prompt "$(__k8s_ns_refresh; echo $__k8s_ns)> " \
      --bind "start:reload:zsh $__k all_pods" \
      --bind "ctrl-r:reload:zsh $__k all_pods" \
      --bind 'ctrl-y:execute-silent(echo -n {1} | xsel --clipboard)+abort' \
      --bind 'alt-e:execute(kubectl exec -it {1} -- sh)' \
      --bind 'alt-l:execute(kubectl logs --follow --tail=2000 {1})' \
      --bind "alt-p:become(zsh $__k _fzf_kubernetes_ports {1})" \
      --bind 'ctrl-/:toggle-preview' \
      --preview-window down,border-top,70%,follow \
      --preview 'kubectl logs --follow --tail=1000 {1}' |
        cut --delimiter=' ' --fields=1
}

if [[ $# -gt 0 ]]; then
  namespaces() {
    kubectl get namespaces
  }
  pods() {
    kubectl get pods "$@"
  }
  ports() {
    (echo -e "PORT\tNAME\tPROTOCOL"; kubectl get pod $1 -o jsonpath="{range .spec.containers[*].ports[*]}{.containerPort}{'\t'}{.name}{'\t'}{.protocol}{'\n'}{end}") | column -t
  }
  case "$1" in
    namespaces)
      namespaces
      ;;
    all_pods)
      pods
      ;;
    running_pods)
      pods --field-selector status.phase=Running
      ;;
    ports)
      ports $2
      ;;
    _fzf_kubernetes_ports)
      _fzf_kubernetes_ports $2
      ;;
  esac
fi

__fzf_widget_init kubernetes '^e' namespaces list ports

# Registering this widget separately as I want it to replace the zsh buffer completely. The other
# widgets append to the left of the cursor and can be used together with kubectl commands.
zle -N _fzf_kubernetes_forward
for m in emacs vicmd viins; do
  eval "bindkey -M $m '^ef' _fzf_kubernetes_forward"
done

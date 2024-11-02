#!/usr/bin/env zsh
# Fuzzy searchable DHIS2 work control panel using https://github.com/junegunn/fzf.

__w=$0:A

issues() {
  local current_issue="$1"

  echo -e "Issue\t\tStatus"
  fd . --type d --max-depth 1 --base-directory "$issue_dir" --strip-cwd-prefix \
    --exec-batch printf '%s\n' {} \
  | while IFS= read -r issue; do
    if [[ "$issue" == "$current_issue" ]]; then
      echo -e "$issue\tcurrent"
    else
      echo -e "$issue\t"
    fi
  done
}

# Widget to list DHIS2 jira issues.
_fzf_work_list() {
  issue_dir="$HOME/code/dhis2/notes/issues/"
  current_issue="$(basename "$(readlink -f "$HOME/code/dhis2/current_issue")")"
  issue_url_prefix="https://dhis2.atlassian.net/browse/"

# TODO execute-become to jump to dir
# TODO make tmux popup? or does that not work with cd
  issues "$current_issue" |
      fzf --border-label "DHIS2 issues (current: $current_issue)" \
      --header 'CTRL-Y (copy Jira) / ALT-O (open Jira)' --header-lines=1 \
      --bind 'ctrl-y:execute-silent(echo -n {1} | xsel --clipboard)+abort' \
      --bind "ctrl-y:execute-silent(echo -n $issue_url_prefix{1}| xsel --clipboard)+abort" \
      --bind "alt-o:execute-silent(open $issue_url_prefix{1})" \
      --bind "alt-c:become(cd $issue_dir{1})" \
      --preview "bat --style=numbers --color=always $issue_dir{1}/{1}.md" \
      --preview-window right,70% |
        cut --fields=1
}

__fzf_work_join() {
  local item
  while read item; do
    echo -n "${(q)item} "
  done
}

__fzf_work_init() {
  local m o
  for o in "$@"; do
    eval "fzf-work-$o-widget() { local result=\$(_fzf_work_$o | __fzf_work_join); zle reset-prompt; LBUFFER+=\$result }"
    eval "zle -N fzf-work-$o-widget"
    for m in emacs vicmd viins; do
      eval "bindkey -M $m '^w^${o[1]}' fzf-work-$o-widget"
      eval "bindkey -M $m '^w${o[1]}' fzf-work-$o-widget"
    done
  done
}
__fzf_work_init list

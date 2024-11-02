#!/usr/bin/env zsh
# Fuzzy searchable DHIS2 issues control panel using https://github.com/junegunn/fzf.

__i=$0:A

# Widget to list DHIS2 jira issues.
_fzf_issues_list() {
  issue_dir="$HOME/code/dhis2/notes/issues"
  current_issue="$(basename "$(readlink -f "$HOME/code/dhis2/current_issue")")"
  issue_url_prefix="https://dhis2.atlassian.net/browse/"

# TODO preview issue.md
      # --preview-window down,border-top,75%,follow \
      # --preview 'docker logs --follow --tail=200 {1}' |
# TODO execute-become to jump to dir
# TODO make tmux popup?
  fd . --type d --max-depth 1 --base-directory "$issue_dir" --strip-cwd-prefix --exec-batch printf '%s\n' {} |
      fzf --border-label "DHIS2 issues (current: $current_issue)" \
      --header 'CTRL-Y (copy Jira) / ALT-O (open Jira)' --header-lines=1 \
      --query "$current_issue" \
      --bind 'ctrl-y:execute-silent(echo -n {1} | xsel --clipboard)+abort' \
      --bind "ctrl-y:execute-silent(echo -n $issue_url_prefix{1}| xsel --clipboard)+abort" \
      --bind "alt-o:execute-silent(open $issue_url_prefix{1})" \
      --bind 'ctrl-/:toggle-preview' |
        cut --delimiter=' ' --fields=1
}

__fzf_issues_join() {
  local item
  while read item; do
    echo -n "${(q)item} "
  done
}

__fzf_issues_init() {
  local m o
  for o in "$@"; do
    eval "fzf-issues-$o-widget() { local result=\$(_fzf_issues_$o | __fzf_issues_join); zle reset-prompt; LBUFFER+=\$result }"
    eval "zle -N fzf-issues-$o-widget"
    for m in emacs vicmd viins; do
      eval "bindkey -M $m '^i' fzf-issues-$o-widget"
    done
  done
}
# TODO this affects tab completion in a weird way
__fzf_issues_init list

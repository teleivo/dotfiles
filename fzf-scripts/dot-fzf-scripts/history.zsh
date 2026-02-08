#!/usr/bin/env zsh
# Fuzzy shell history search using fzf + atuin's SQLite database.
# Replaces atuin's search with fzf's fuzzy matching while keeping atuin for
# recording and backup. Supports directory-scoped and global search.
#
# ctrl-r: open history search (directory-scoped by default), toggle dir/global
# ctrl-y: copy selected command to clipboard
# alt-d:  delete selected command from history
# enter:  execute selected command
# tab:    place selected command on the command line without executing

__h=$0:A
__h_db="$HOME/Documents/.atuin-history.db"

if [[ $# -gt 0 ]]; then
  case "$1" in
    dir)
      local cwd="${_FZF_HIST_CWD//\'/\'\'}"
      sqlite3 "$__h_db" "select command from history where cwd = '$cwd' and deleted_at is null group by command order by max(timestamp) desc"
      ;;
    global)
      sqlite3 "$__h_db" "select command from history where deleted_at is null group by command order by max(timestamp) desc"
      ;;
    delete)
      local cmd
      IFS= read -r cmd
      local escaped="${cmd//\'/\'\'}"
      sqlite3 "$__h_db" "update history set deleted_at = datetime('now') where command = '$escaped' and deleted_at is null"
      ;;
  esac
  return 0
fi

_fzf_history_search() {
  local cwd="$PWD"
  local short="${cwd##*/}"

  _FZF_HIST_CWD="$cwd" fzf \
    --scheme=history \
    --border-label "history [dir: $short]" \
    --header 'ctrl-r: toggle dir/global  |  ctrl-y: copy  |  alt-d: delete  |  enter: execute  |  tab: edit' \
    --no-multi \
    --expect=tab \
    --bind 'start:reload:zsh '"$__h"' dir' \
    --bind 'ctrl-y:execute-silent(echo -n {} | xsel --clipboard)+abort' \
    --bind 'alt-d:execute-silent(echo {} | zsh '"$__h"' delete)+transform:[[ $FZF_BORDER_LABEL =~ dir ]] &&
      echo "reload:zsh '"$__h"' dir" ||
      echo "reload:zsh '"$__h"' global"' \
    --bind 'ctrl-r:transform:[[ $FZF_BORDER_LABEL =~ dir ]] &&
      echo "change-border-label(history [global])+reload:zsh '"$__h"' global" ||
      echo "change-border-label(history [dir: '"$short"'])+reload:zsh '"$__h"' dir"'
}

fzf-history-widget() {
  local output key cmd
  output=$(_fzf_history_search)
  key=$(head -1 <<< "$output")
  cmd=$(sed -n '2p' <<< "$output")

  if [[ -n "$cmd" ]]; then
    LBUFFER="$cmd"
    RBUFFER=""
    if [[ "$key" != "tab" ]]; then
      zle accept-line
    fi
  fi
  zle reset-prompt
}

zle -N fzf-history-widget
for m in emacs vicmd viins; do
  bindkey -M $m '^R' fzf-history-widget
done

#!/usr/bin/env zsh
# Fuzzy shell history search using fzf + atuin's SQLite database.
# Replaces atuin's search with fzf's fuzzy matching while keeping atuin for
# recording and backup. Supports directory-scoped and global search.
#
# This file serves two roles:
# 1. Sourced by zshrc: defines the fzf-history-widget and binds ctrl-r
# 2. Called as a script by fzf's reload/execute bindings for data operations
#
# ctrl-r: open history search (directory-scoped by default), toggle dir/global
# ctrl-y: copy selected command to clipboard
# alt-d:  delete selected command from history
# ctrl-/: toggle preview (run count, exit stats, recent runs with directories)
# enter:  execute selected command
# tab:    place selected command on the command line without executing

__h=$0:A
__h_db="$HOME/Documents/.atuin-history.db"

# SQL fragment for the display format: colored exit indicator + command.
# char(27)=ESC for ANSI colors, char(31)=Unit Separator as fzf field delimiter
# (invisible, used with --delimiter/--nth to exclude indicator from search).
# Continuation lines are indented 2 spaces to align with the "✓ " prefix.
__h_exit_indicator="case
    when exit = 0 then char(27) || '[32m✓' || char(27) || '[0m'
    when exit < 0 then char(27) || '[90m·' || char(27) || '[0m'
    else char(27) || '[31m✗' || char(27) || '[0m'
  end || ' ' || char(31) || replace(command, char(10), char(10) || '  ')"

# Atuin stores timestamps in nanoseconds since epoch.
__h_ns=1000000000

# When called with arguments, act as a data source for fzf's bind commands.
if [[ $# -gt 0 ]]; then
  case "$1" in
    dir|global)
      local where="deleted_at is null"
      if [[ "$1" == "dir" ]]; then
        local cwd="${_FZF_HIST_CWD//\'/\'\'}"
        where="cwd = '$cwd' and $where"
      fi
      # Record Separator (0x1E) as sqlite3 row delimiter, converted to NUL for
      # fzf --read0 so multi-line commands are treated as single items.
      sqlite3 -cmd '.separator "" "\x1e"' "$__h_db" \
        "select $__h_exit_indicator from (
          select command, exit, timestamp,
            row_number() over (partition by command order by timestamp desc) as rn
          from history where $where
        ) where rn = 1 order by timestamp desc" \
        | tr '\036' '\0'
      ;;
    strip)
      # Extract the raw command from fzf's display format by removing the exit
      # indicator prefix (everything before Unit Separator) and the 2-space
      # continuation line padding.
      local raw nl=$'\n' pad=$'\n  '
      raw=$(cat)
      raw="${raw#*$'\x1f'}"
      raw="${raw//$pad/$nl}"
      printf '%s' "$raw"
      ;;
    preview)
      local cmd
      cmd=$(cat)
      local escaped="${cmd//\'/\'\'}"
      local where="command = '$escaped' and deleted_at is null"
      sqlite3 "$__h_db" "
        select
          count(*) || ' runs  (' ||
          sum(case when exit = 0 then 1 else 0 end) || ' ok  ' ||
          sum(case when exit > 0 then 1 else 0 end) || ' fail)' ||
          char(10) ||
          'last: ' || datetime(max(timestamp) / $__h_ns, 'unixepoch', 'localtime') ||
          '  first: ' || datetime(min(timestamp) / $__h_ns, 'unixepoch', 'localtime') ||
          char(10) ||
          'avg: ' || printf('%.1fs', avg(case when duration > 0 then duration else null end) / ${__h_ns}.0) ||
          '  max: ' || printf('%.1fs', max(case when duration > 0 then duration else null end) / ${__h_ns}.0)
        from history where $where;
        select '';
        select
          case when exit = 0 then '✓' when exit < 0 then '·' else '✗' end ||
          ' ' || datetime(timestamp / $__h_ns, 'unixepoch', 'localtime') ||
          '  ' || printf('%6.1fs', duration / ${__h_ns}.0) ||
          '  ' || replace(cwd, '$HOME', '~')
        from history where $where
        order by timestamp desc
        limit 20"
      ;;
    delete)
      local cmd
      cmd=$(cat)
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
    --ansi \
    --delimiter=$'\x1f' --nth=2.. \
    --border-label "history [dir: $short]" \
    --header 'ctrl-r: toggle dir/global  |  ctrl-y: copy  |  alt-d: delete  |  enter: execute  |  tab: edit' \
    --no-multi \
    --read0 \
    --expect=tab \
    --preview 'echo -n {} | zsh '"$__h"' strip | zsh '"$__h"' preview' \
    --preview-window down,border-top,40%,hidden \
    --bind 'start:reload:zsh '"$__h"' dir' \
    --bind 'ctrl-y:execute-silent(echo -n {} | zsh '"$__h"' strip | xsel --clipboard)+abort' \
    --bind 'alt-d:execute-silent(echo -n {} | zsh '"$__h"' strip | zsh '"$__h"' delete)+transform:[[ $FZF_BORDER_LABEL =~ dir ]] &&
      echo "reload:zsh '"$__h"' dir" ||
      echo "reload:zsh '"$__h"' global"' \
    --bind 'ctrl-r:transform:[[ $FZF_BORDER_LABEL =~ dir ]] &&
      echo "change-border-label(history [global])+reload:zsh '"$__h"' global" ||
      echo "change-border-label(history [dir: '"$short"'])+reload:zsh '"$__h"' dir"'
}

fzf-history-widget() {
  local output key cmd
  output=$(_fzf_history_search)
  key="${output%%$'\n'*}"
  cmd="${output#*$'\n'}"

  # strip exit code indicator and continuation line padding
  local nl=$'\n' pad=$'\n  '
  cmd="${cmd#*$'\x1f'}"
  cmd="${cmd//$pad/$nl}"

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

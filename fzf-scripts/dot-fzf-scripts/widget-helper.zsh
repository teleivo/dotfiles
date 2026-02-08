#!/usr/bin/env zsh
# Shared helper for fzf widget registration.
# Provides __fzf_widget_join and __fzf_widget_init used by docker, kubernetes, and work widgets.

__fzf_widget_join() {
  local item
  while read item; do
    echo -n "${(q)item} "
  done
}

# Register fzf widgets for a given prefix and list of object names.
# Usage: __fzf_widget_init <prefix> <keybind-prefix> <object1> <object2> ...
#
# For each object, this creates a widget "fzf-<prefix>-<object>-widget" that
# calls "_fzf_<prefix>_<object>", joins the output, and pastes it into LBUFFER.
# The widget is bound to <keybind-prefix>^<first-letter> and
# <keybind-prefix><first-letter> in emacs, vicmd, and viins keymaps.
__fzf_widget_init() {
  local prefix=$1 kprefix=$2
  shift 2
  local m o
  for o in "$@"; do
    eval "fzf-$prefix-$o-widget() { local result=\$(_fzf_${prefix}_$o | __fzf_widget_join); zle reset-prompt; LBUFFER+=\$result }"
    eval "zle -N fzf-$prefix-$o-widget"
    for m in emacs vicmd viins; do
      eval "bindkey -M $m '${kprefix}^${o[1]}' fzf-$prefix-$o-widget"
      eval "bindkey -M $m '${kprefix}${o[1]}' fzf-$prefix-$o-widget"
    done
  done
}

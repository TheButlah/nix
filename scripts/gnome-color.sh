#!/usr/bin/env bash
set -Eeuo pipefail

KEY="/org/gnome/desktop/interface/color-scheme"
SIGNAL_NUM=9   # must match your waybar module's "signal" value

get_scheme() {
  # Typical outputs:  'prefer-dark'  or  'prefer-light'  or  'default'
  local v
  v="$(dconf read "$KEY" 2>/dev/null || true)"
  v="${v//\'/}"     # strip single quotes
  v="${v//\"/}"     # strip double quotes (in case you wrote with them)
  echo "$v"
}

status_json() {
  local v icon cls tip
  v="$(get_scheme)"

  case "$v" in
    prefer-dark)
      icon=""  # Font Awesome moon (swap to 🌙 if you prefer)
      cls="dark"
      tip="GNOME color-scheme: prefer-dark"
      ;;
    prefer-light)
      icon="☀️"  # Font Awesome sun  (swap to ☀️ if you prefer)
      cls="light"
      tip="GNOME color-scheme: prefer-light"
      ;;
    default|"")
      icon=""
      cls="default"
      tip="GNOME color-scheme: default (click to toggle)"
      ;;
    *)
      icon=""
      cls="unknown"
      tip="GNOME color-scheme: ${v}"
      ;;
  esac

  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$icon" "$tip" "$cls"
}

toggle() {
  local v new
  v="$(get_scheme)"

  if [[ "$v" == "prefer-dark" ]]; then
    new="prefer-light"
  else
    new="prefer-dark"
  fi

  # NOTE: pass a GVariant string literal (the inner single-quotes matter)
  dconf write "$KEY" "'$new'"

  # Ask waybar to refresh this module immediately (since interval=once)
  pkill -RTMIN+"$SIGNAL_NUM" waybar 2>/dev/null || true
}

case "${1:-status}" in
  status) status_json ;;
  toggle) toggle ;;
  *) echo "usage: $0 [status|toggle]" >&2; exit 2 ;;
esac

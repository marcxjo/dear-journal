#!/usr/bin/env bash

[ -f "${DEAR_JOURNAL_LIB_DIR}/core.sh" ] && . "${DEAR_JOURNAL_LIB_DIR}/core.sh"

# Legend command ###############################################################

cmd_legend() {
  declare -r legend_file="${PASS_JOURNAL_DIR}/legend"

  [ ! -r "$legend_file" ] &&
    echo "Unable to read journal legend - are you sure it exists?" &&
    return 1

  cat "$legend_file"
}

# Daily command ################################################################

daily_new() {
  local -r date="${1:-today}"
  local -r entry_path=$(date -d "$date" '%Y/%m/%d')
  local -r fq_entry_path="${PASS_JOURNAL_DIR}/daily/${entry_path}"
  local -i entry_num=1

  if [[ -d "$fq_entry_path" ]]; then
    # shellcheck disable=SC2034
    # Used via nameref
    readarray -t entries <<<"$(__ls_dirs "$fq_entry_path")"
    entry_num=$(__get_next_num "${entries[@]}")
  fi

  dear_core_edit "${fq_entry_path}/${entry_num}/entry"
}

cmd_daily() {
  case "$1" in
  'new')
    daily_new
    ;;
  '*')
    echo "Unknown subcommand $1"
    return 1
    ;;
  esac
}

# Main loop ####################################################################

declare -r subcmd="$1" && shift

case "$subcmd" in
'legend')
  cmd_legend "$@"
  ;;
'daily')
  cmd_daily "$@"
  ;;
esac

#!/usr/bin/env bash

if [[ "${HAS_LIBDEAR_CORE+1}" == '1' ]]; then
  return
fi

HAS_LIBDEAR_CORE=1

# Private functions ############################################################

dear_core_private_pass() {
  PASSWORD_STORE_DIR="$DEAR_JOURNAL_DIR" pass "$@"
}

dear_core_private_pass_ls_to_depth() {
  local -r entry_path="$1"
  local -r tree_header="$2"
  local -ri max_dir_depth=$3
  local -r summary_descriptor_singular="$4"
  local -r summary_descriptor_plural="$5"

  echo "$tree_header"

  local -i summarized_count=0
  local last_summary_line

  # Preserve leading whitespace in the `tree` output
  local IFS=''

  # Run the tree command provided by pass, but rather than show entry
  # file names (since they're not really meaningful from a user perspective),
  # simply show the total entry count per day
  while read -r line; do
    if grep -P "^(?:(?:\s|│)\s{3}){${max_dir_depth}}" <<<"$line" >/dev/null; then
      summarized_count=$((summarized_count + 1))
      last_summary_line="$line"
    elif [[ $summarized_count -eq 1 ]]; then
      printf '%s %d %s\n' "${last_summary_line% *}" "$summarized_count" "$summary_descriptor_singular"
      summarized_count=0
      unset last_summary_line
      printf '%s\n' "$line"
    elif [[ $summarized_count -gt 0 ]]; then
      printf '%s %d %s\n' "${last_summary_line% *}" "$summarized_count" "$summary_descriptor_plural"
      summarized_count=0
      unset last_summary_line
      printf '%s\n' "$line"
    else
      printf '%s\n' "$line"
    fi
  done <<<"$(dear_core_private_pass 'ls' "$entry_path" | tail -n+2)"

  # If our last directory contains entries, we will not have already emitted
  # output to indicate this, so we check one last time to determine whether we
  # were in the middle of counting entries in a directory
  if [[ $summarized_count -eq 1 ]]; then
    printf '%s %d %s\n' "${last_summary_line% *}" "$summarized_count" "$summary_descriptor_singular"
  elif [[ $summarized_count -gt 0 ]]; then
    printf '%s %d %s\n' "${last_summary_line% *}" "$summarized_count" "$summary_descriptor_plural"
  fi
}

# Public API ###################################################################

dear_core_pass_init() {
  if dear_core_private_pass init "$@" 2>/dev/null; then
    return
  fi

  return 1
}

dear_core_pass_edit() {
  local -r path="$1"

  dear_core_private_pass edit "${path}" 2>/dev/null
}

dear_core_pass_ls() {
  local -r entry_path="$1"
  local -r tree_header="$2"
  local -ri num_indents=$3

  dear_core_private_pass_ls_to_depth "$entry_path" "$tree_header" "$num_indents" 'entry' 'entries'
}

dear_core_pass_grep() {
  dear_core_private_pass 'grep' "$@"
}

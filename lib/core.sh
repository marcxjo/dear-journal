#!/usr/bin/env bash

if [[ "${HAS_LIBDEAR_CORE+1}" == '1' ]]; then
  return
fi

HAS_LIBDEAR_CORE=1

# Private functions ############################################################

dear_core_private_tree() {
  local -r root_dir="$1"
  local -i depth

  [[ $2 -gt 0 ]] && depth=$2

  "$TREE_CMD" -N -C -l "${depth:+-L}" ${depth} --noreport "$root_dir" | tail -n+2
}

dear_core_private_pass() {
  PASSWORD_STORE_DIR="$DEAR_JOURNAL_DIR" "$PASS_CMD" "$@"
}

dear_core_private_pass_ls_to_depth() {
  local -r entry_path="$1"
  local -r tree_header="$2"
  local -ri max_dir_depth=$3
  local -r summary_descriptor_singular="$4"
  local -r summary_descriptor_plural="$5"

  echo "$tree_header"

  # Counts the entries under a given directory at summarizing depth
  local -i summarized_count=0
  # Captures the substring containing the "branch" glyphs for the summary line
  # we print for max-depth directories
  local summary_branch_str
  # Captures indent levels to determine the nesting depth indicated by a line of
  # `tree` output
  local -a dir_depths=()

  # Preserve leading whitespace in the `tree` output
  local IFS=''

  # Run the tree command provided by pass, but rather than show entry
  # file names (since they're not really meaningful from a user perspective),
  # simply show the total entry count per day
  while read -r line; do
    # Truncating the line starting at the first alphanumeric yields the branch
    # string and any leading whitespace
    indentation="${line%%[[:alnum:]]*}"

    # Disable warning about quotes on array entries that we know are integers
    # shellcheck disable=SC2086
    if [[ ${#dir_depths[@]} -eq 0 ]]; then
      # Capture the indentation of the first line
      dir_depths+=(${#indentation})
    elif [[ ${#dir_depths[@]} -gt 0 ]] &&
      [[ ${#dir_depths[@]} -lt ${max_dir_depth} ]] &&
      [[ ${#indentation} -gt ${dir_depths[$((${#dir_depths[@]} - 1))]} ]]; then
      # We've just traversed a new nesting depth for the first time
      dir_depths+=(${#indentation})
    fi

    # shellcheck disable=SC2086
    if [[ ${#dir_depths[@]} -ge ${max_dir_depth} ]] &&
      [[ ${#indentation} -gt ${dir_depths[$((max_dir_depth - 1))]} ]]; then
      # The current line represents the first entry nested low enough to start a
      # summary line
      summarized_count=$((summarized_count + 1))
      summary_branch_str="${indentation% *}"
    elif [[ $summarized_count -eq 1 ]]; then
      # We have escaped summary depth, having found one nested item
      printf '%s %d %s\n' "${summary_branch_str}" "$summarized_count" "$summary_descriptor_singular"
      summarized_count=0
      unset summary_branch_str
      printf '%s\n' "$line"
    elif [[ $summarized_count -gt 0 ]]; then
      # We have escaped summary depth, having found multiple nested items
      printf '%s %d %s\n' "${summary_branch_str}" "$summarized_count" "$summary_descriptor_plural"
      summarized_count=0
      unset summary_branch_str
      printf '%s\n' "$line"
    else
      # We're on an item above summarizing depth
      printf '%s\n' "$line"
    fi
  done <<<"$(dear_core_private_pass 'ls' "$entry_path" | tail -n+2)"

  # If our last directory contains entries, we will not have already emitted
  # output to indicate this, so we check one last time to determine whether we
  # were in the middle of counting entries in a directory
  if [[ $summarized_count -eq 1 ]]; then
    printf '%s %d %s\n' "${summary_branch_str}" "$summarized_count" "$summary_descriptor_singular"
  elif [[ $summarized_count -gt 0 ]]; then
    printf '%s %d %s\n' "${summary_branch_str}" "$summarized_count" "$summary_descriptor_plural"
  fi
}

# Public API ###################################################################

dear_core_pass_init() {
  while IFS='' read -r line; do
    if [[ "$line" =~ "Password store" ]]; then
      printf '%s\n' "${line/Password store/Journal}"
    fi
  done < <(dear_core_private_pass init "$@" 2>/dev/null)

  # Capture the status of the `pass` command so that we can alert the user if it
  # fails
  wait $!

  return $?
}

dear_core_pass_edit() {
  local -r path="$1"

  dear_core_private_pass edit "${path}" 2>/dev/null
}

dear_core_pass_ls() {
  local -r entry_path="$1"
  local -r tree_header="$2"
  local -ri num_indents=$3

  dear_core_private_pass_ls_to_depth "$entry_path" "$tree_header" $num_indents 'entry' 'entries'
}

dear_core_pass_grep() {
  dear_core_private_pass 'grep' "$@"
}

#!/bin/bash

if [[ "${HAS_DEAR_CORE+1}" == '1' ]]; then
  return
fi

HAS_DEAR_CORE=1

dear_core_edit() {
  local -r path="$1"

  if exec_pass edit "${path}" 2>/dev/null; then
    return
  fi

  echo_err "Journal entry was not saved."

  return 1
}

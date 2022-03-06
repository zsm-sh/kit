#!/usr/bin/env bash

# Check a command exist
function runtime::command_exist() {
  local command="${1}"
  type "${command}" >/dev/null 2>&1
}

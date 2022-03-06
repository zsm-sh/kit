#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/is_output.sh"

# Print message to stderr with timestamp
function log::info() {
    local v="0"
    local key

    if [[ $# -gt 1 ]]; then
        key="${1}"
        case ${key} in
        -v | -v=*)
            [[ "${key#*=}" != "$key" ]] && v="${key#*=}" || { v="${2}" && shift; }
            if ! log::is_output "${v}" ; then
                return
            fi
            shift
            ;;
        *) ;;
        esac
    fi

    if [[ "${v}" -gt 0 ]]; then
        echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] INFO(${v}) ${*}" >&2
        return
    fi
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] INFO ${*}" >&2
}

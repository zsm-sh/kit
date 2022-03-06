#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/verbose.sh"

# whether to output
function log::is_output() {
    local v="${1}"
    if [[ "${v}" -gt "$(log::verbose)" ]]; then
        return 1
    fi
}

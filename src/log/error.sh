#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../runtime/stack_trace.sh"

# Print error message and stack trace to stderr with timestamp
function log::error() {
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] ERROR ${*}" >&2
    runtime::stack_trace 1 >&2
}

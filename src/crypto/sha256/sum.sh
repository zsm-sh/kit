#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../../log/error.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../runtime/command_exist.sh"

# get the sha256 for file
function crypto::sha256::sum() {
    local file="${1}"
    if runtime::command_exist sha256sum; then
        sha256sum "${file}" | awk '{print $1}'
    elif runtime::command_exist shasum; then
        shasum -a 256 "${file}" | awk '{print $1}'
    else
        log::error "Neither sha256sum nor shasum are available"
        exit 1
    fi
}
#!/usr/bin/env bash

function utils::git_latest_tag() (
    local dir="${1}"

    cd "${dir}" || return 1

    git tag -n | sort -rV | head -n 1 | awk '{print $1}'
)
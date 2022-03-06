#!/usr/bin/env bash

function utils::git_sum() (
    local dir="${1}"

    cd "${dir}" || return 1

    git log -n1 --format=format:"%H"
)
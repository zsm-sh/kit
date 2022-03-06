#!/usr/bin/env bash

function git::sum() (
    local dir="${1}"

    cd "${dir}" || return 1

    git log -n1 --format=format:"%H"
)
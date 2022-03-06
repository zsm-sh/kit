#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../../vendor/std/src/log/info.sh"

function git::fetch() (
    local dir="${1}"
    local repo="${2}"
    local tag="${3:-}"
    local branch="main"
    local origin="origin"
    local oriurl

    if [[ ! -d "${dir}" ]]; then
        log::info -v=1 "Creating directory ${dir}"
        mkdir -p "${dir}"
    fi

    cd "${dir}" || return 1

    if [[ ! -d .git ]]; then
        log::info -v=1 "Initializing git repository in ${dir}"
        if log::is_output 4; then
            git init
        else
            git init --quiet
        fi
    fi

    oriurl=$(git remote get-url ${origin} 2>/dev/null)
    if [[ $? -eq 0 ]]; then
        if [[ "${oriurl}" != "${repo}" ]]; then
            git remote set-url "${origin}" "${repo}"
        fi
    else
        git remote add "${origin}" "${repo}"
    fi

    if [[ "${tag}" != "" ]]; then
        if [[ "${tag}" != "$(git describe --tags 2>/dev/null)" ]]; then
            log::info -v=1 "Fetching ${repo} ${tag} to ${dir}"
            if log::is_output 4; then
                git fetch "${origin}" tag "${tag}"
                git checkout -f -B "${branch}" "${tag}"
            else
                git fetch "${origin}" tag "${tag}" >/dev/null 2>&1
                git checkout -f -B "${branch}" "${tag}" >/dev/null 2>&1
            fi
            log::info -v=1 "Fetched ${repo} ${tag} to ${dir}"
        else
            log::info -v=1 "Git ${repo} ${tag} already fetched to ${dir}"
        fi
    else
        log::info -v=1 "Fetching ${repo} to ${dir}"
        if log::is_output 4; then
            git fetch --tags "${origin}"
        else
            git fetch --tags "${origin}" >/dev/null 2>&1
        fi
        log::info -v=1 "Fetched ${repo} to ${dir}"
    fi

)

#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/crypto/sha256/sum.sh"
source "$(dirname "${BASH_SOURCE[0]}")/log/error.sh"
source "$(dirname "${BASH_SOURCE[0]}")/log/info.sh"
source "$(dirname "${BASH_SOURCE[0]}")/utils/download.sh"
source "$(dirname "${BASH_SOURCE[0]}")/utils/git_fetch.sh"
source "$(dirname "${BASH_SOURCE[0]}")/utils/git_sum.sh"
source "$(dirname "${BASH_SOURCE[0]}")/utils/git_latest_tag.sh"



modfile="${1}"
modfile="$(realpath "${modfile}")"
dir="$(dirname "${modfile}")"


function require::file() {
    local file="${1}"
    local url="${2}"
    local checksum="${3:-}"
    utils::download "${file}" "${url}"
    if [[ "${checksum}" == "" ]]; then
        checksum=$(crypto::sha256::sum "${file}")
        if [[ "${checksum}" == "" ]]; then
            log::error "Fail get sha256 of ${file}"
            return 1
        fi

        sed "s| ${file} ${url}$| ${file} ${url} ${checksum}|" "${modfile}" > "${modfile}.tmp"
        mv "${modfile}.tmp" "${modfile}"
    fi

    if [[ "${checksum}" != "$(crypto::sha256::sum "${file}")" ]]; then
        log::error "File ${file} downloaded but its checksum is incorrect (expected ${checksum}, got $(crypto::sha256::sum "${file}"))"
        return 1
    fi
}

function require::git() {
    local dir="${1}"
    local url="${2}"
    local tag="${3:-}"
    local checksum="${4:-}"

    utils::git_fetch "${dir}" "${url}" "${tag}"

    if [[ "${tag}" == "" ]]; then
        tag=$(utils::git_latest_tag "${dir}")
        if [[ "${tag}" == "" ]]; then
            log::error "Fail get tag of ${dir}"
            return 1
        fi
        utils::git_fetch "${dir}" "${url}" "${tag}"
        sed "s| ${dir} ${url}$| ${dir} ${url} ${tag}|" "${modfile}" > "${modfile}.tmp"
        mv "${modfile}.tmp" "${modfile}"
    fi

    if [[ "${checksum}" == "" ]]; then
        checksum=$(utils::git_sum "${dir}")
        if [[ "${checksum}" == "" ]]; then
            log::error "Fail get hash of ${dir}"
            return 1
        fi
        sed "s| ${dir} ${url} ${tag}$| ${dir} ${url} ${tag} ${checksum}|" "${modfile}" > "${modfile}.tmp"
        mv "${modfile}.tmp" "${modfile}"
    fi

    if [[ "${checksum}" != "$(utils::git_sum "${dir}")" ]]; then
        log::error "Git repo ${dir} downloaded but its checksum is incorrect (expected ${checksum}, got $(utils::git_sum "${dir}"))"
        return 1
    fi
}

(cd "${dir}" && source "${modfile}")

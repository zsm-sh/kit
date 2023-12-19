#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../vendor/std/src/crypto/sha256/sum.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../vendor/std/src/log/error.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../vendor/std/src/log/info.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../vendor/std/src/http/download.sh"
source "$(dirname "${BASH_SOURCE[0]}")/git/fetch.sh"
source "$(dirname "${BASH_SOURCE[0]}")/git/sum.sh"
source "$(dirname "${BASH_SOURCE[0]}")/git/latest_tag.sh"

# Setup the file form the given URL.
function kit::file() {
    local file="${1}"
    local url="${2}"
    local checksum="${3:-}"

    if [[ "${checksum}" != "" ]]; then
        current=$(crypto::sha256::sum "${file}")
        if [[ "${current}" == "${checksum}" ]]; then
            return
        fi
    fi

    rm -f "${file}"
    http::download "${file}" "${url}"
    if [[ "${checksum}" == "" ]]; then
        checksum=$(crypto::sha256::sum "${file}")
        if [[ "${checksum}" == "" ]]; then
            log::error "Fail get sha256 of ${file}"
            return 1
        fi

        sed "s|^\(file\s\+${file}\s\+${url}\s*\)$|\1 ${checksum}|" "${modfile}" >"${modfile}.tmp"
        mv "${modfile}.tmp" "${modfile}"
    fi

    if [[ "${checksum}" != "$(crypto::sha256::sum "${file}")" ]]; then
        log::error "File ${file} downloaded but its checksum is incorrect (expected ${checksum}, got $(crypto::sha256::sum "${file}"))"
        return 1
    fi
}

# Setup the binary file from given URL
function kit::bin() {
    local file="${1}"
    local url="${2}"
    local checksum="${3:-}"

    if [[ "${checksum}" != "" ]]; then
        current=$(crypto::sha256::sum "${file}")
        if [[ "${current}" == "${checksum}" ]]; then
            return
        fi
    fi

    rm -f "${file}"
    http::download "${file}" "${url}"
    if [[ "${checksum}" == "" ]]; then
        checksum=$(crypto::sha256::sum "${file}")
        if [[ "${checksum}" == "" ]]; then
            log::error "Fail get sha256 of ${file}"
            return 1
        fi

        sed "s|^\(bin\s\+${file}\s\+${url}\s*\)$|\1 ${checksum}|" "${modfile}" >"${modfile}.tmp"
        mv "${modfile}.tmp" "${modfile}"
    fi

    if [[ "${checksum}" != "$(crypto::sha256::sum "${file}")" ]]; then
        log::error "File ${file} downloaded but its checksum is incorrect (expected ${checksum}, got $(crypto::sha256::sum "${file}"))"
        return 1
    fi

    chmod +x "${file}"
}

# Setup the git directory from the given URL.
function kit::git() {
    local dir="${1}"
    local url="${2}"
    local tag="${3:-}"
    local checksum="${4:-}"

    git::fetch "${dir}" "${url}" "${tag}"

    if [[ "${tag}" == "" ]]; then
        tag=$(git::latest_tag "${dir}")
        if [[ "${tag}" == "" ]]; then
            log::error "Fail get tag of ${dir}"
            return 1
        fi
        git::fetch "${dir}" "${url}" "${tag}"
        sed "s|^\(git\s\+${dir}\s\+${url}\s*\)$|\1 ${tag}|" "${modfile}" >"${modfile}.tmp"
        mv "${modfile}.tmp" "${modfile}"
    fi

    if [[ "${checksum}" == "" ]]; then
        checksum=$(git::sum "${dir}")
        if [[ "${checksum}" == "" ]]; then
            log::error "Fail get hash of ${dir}"
            return 1
        fi
        sed "s|^\(git\s\+${dir}\s\+${url}\s\+${tag}\s*\)$|\1 ${checksum}|" "${modfile}" >"${modfile}.tmp"
        mv "${modfile}.tmp" "${modfile}"
    fi

    if [[ "${checksum}" != "$(git::sum "${dir}")" ]]; then
        log::error "Git repo ${dir} downloaded but its checksum is incorrect (expected ${checksum}, got $(git::sum "${dir}"))"
        return 1
    fi
}

function kit() {
    local modfile="${1}"
    local dir
    modfile="$(realpath "${modfile}")"
    dir="$(dirname "${modfile}")"
    cd "${dir}"
    IFS=$'\n'
    for line in $(cat "${modfile}"); do
        unset IFS
        read -r -a line <<<"${line}"
        IFS=$'\n'
        if [[ "${line[0]}" == "file" ]]; then
            kit::file "${line[1]}" "${line[2]}" "${line[3]}"
        elif [[ "${line[0]}" == "bin" ]]; then
            kit::bin "${line[1]}" "${line[2]}" "${line[3]}"
        elif [[ "${line[0]}" == "git" ]]; then
            kit::git "${line[1]}" "${line[2]}" "${line[3]}" "${line[4]}"
        elif [[ "${line[0]}" =~ ^# ]]; then
            : # comment ignore
        else
            log::error "Unknown kit type ${line[0]}"
        fi
    done
    unset IFS
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    function usage() {
        echo "Usage: ${0} <file>"
        echo
        echo "Setup the kit from the given file."
        echo
        echo "Example:"
        echo "  ${0} vendor.kit"
        echo
        exit 1
    }

    function main() {
        local modfile="${1}"
        if [[ "${modfile}" == "" ]]; then
            if [[ -f "vendor.kit" ]]; then
                modfile="vendor.kit"
            else
                log::error "Missing vendor.kit"
                usage
            fi
        fi
        if [[ ! -f "${modfile}" ]]; then
            log::error "File ${modfile} not found"
            usage
        fi
        kit "${modfile}"
    }

    main "${@}"
fi

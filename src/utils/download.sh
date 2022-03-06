#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../runtime/command_exist.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../log/error.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../log/info.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../log/is_output.sh"


# Download a file from a URL
# curl or wget are used depending on the availability of curl or wget
function utils::download() {
    local file="${1}"
    local url="${2}"
    local dir
    dir="$(dirname "${file}")"

    if [[ "${dir}" != "." ]] && [[ ! -d "${dir}" ]]; then
        log::info -v=1 "Creating directory ${dir}"
        mkdir -p "${dir}"
    fi

    if [[ -s "${file}" ]]; then
        log::info -v=1 "File ${file} already exists"
        return
    fi

    log::info -v=1 "Downloading ${url} to ${file}"

    if runtime::command_exist wget; then
        if log::is_output 4 ; then
            wget -O "${file}.tmp" "${url}"
        else
            wget -q -O "${file}.tmp" "${url}"
        fi
    elif runtime::command_exist curl; then
        if log::is_output 4 ; then
            curl -L -o "${file}.tmp" "${url}"
        else
            curl -sSL -o "${file}.tmp" "${url}"
        fi
    else
        log::error "Neither curl nor wget are available"
        exit 1
    fi

    mv "${file}.tmp" "${file}"

    log::info -v=1 "Downloaded ${url} to ${file}"
}

#!/usr/bin/env bash
# {{{ source ../vendor/std/src/crypto/sha256/sum.sh
#!/usr/bin/env bash
# {{{ source ../vendor/std/src/log/error.sh
#!/usr/bin/env bash
# {{{ source ../vendor/std/src/runtime/stack_trace.sh
#!/usr/bin/env bash
function runtime::stack_trace() {
    local i=${1:-0}
    while caller $i; do
        ((i++))
    done | awk '{print  "[" NR "] " $3 ":" $1 " " $2}'
}
# }}} source ../vendor/std/src/runtime/stack_trace.sh
# Print error message and stack trace to stderr with timestamp
function log::error() {
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] ERROR ${*}" >&2
    runtime::stack_trace 1 >&2
}
# }}} source ../vendor/std/src/log/error.sh
# {{{ source ../vendor/std/src/runtime/command_exist.sh
#!/usr/bin/env bash
# Check a command exist
function runtime::command_exist() {
  local command="${1}"
  type "${command}" >/dev/null 2>&1
}
# }}} source ../vendor/std/src/runtime/command_exist.sh
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
# }}} source ../vendor/std/src/crypto/sha256/sum.sh
# source ../vendor/std/src/log/error.sh # Embed file already embedded by ../vendor/std/src/crypto/sha256/sum.sh
# {{{ source ../vendor/std/src/log/info.sh
#!/usr/bin/env bash
# {{{ source ../vendor/std/src/log/is_output.sh
#!/usr/bin/env bash
# {{{ source ../vendor/std/src/log/verbose.sh
#!/usr/bin/env bash
# get verbose level
function log::verbose() {
    echo "${LOG_VERBOSE:-0}"
}
# }}} source ../vendor/std/src/log/verbose.sh
# whether to output
function log::is_output() {
    local v="${1}"
    if [[ "${v}" -gt "$(log::verbose)" ]]; then
        return 1
    fi
}
# }}} source ../vendor/std/src/log/is_output.sh
# Print message to stderr with timestamp
function log::info() {
    local v="0"
    local key
    if [[ $# -gt 1 ]]; then
        key="${1}"
        case ${key} in
        -v | -v=*)
            [[ "${key#*=}" != "$key" ]] && v="${key#*=}" || { v="${2}" && shift; }
            if ! log::is_output "${v}" ; then
                return
            fi
            shift
            ;;
        *) ;;
        esac
    fi
    if [[ "${v}" -gt 0 ]]; then
        echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] INFO(${v}) ${*}" >&2
        return
    fi
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] INFO ${*}" >&2
}
# }}} source ../vendor/std/src/log/info.sh
# {{{ source ../vendor/std/src/http/download.sh
#!/usr/bin/env bash
# source ../vendor/std/src/runtime/command_exist.sh # Embed file already embedded by ../vendor/std/src/crypto/sha256/sum.sh
# source ../vendor/std/src/log/error.sh # Embed file already embedded by ../vendor/std/src/crypto/sha256/sum.sh kit.sh
# source ../vendor/std/src/log/info.sh # Embed file already embedded by kit.sh
# source ../vendor/std/src/log/is_output.sh # Embed file already embedded by ../vendor/std/src/log/info.sh
# Download a file from a URL
# curl or wget are used depending on the availability of curl or wget
function http::download() {
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
# }}} source ../vendor/std/src/http/download.sh
# {{{ source git/fetch.sh
#!/usr/bin/env bash
# source ../vendor/std/src/log/info.sh # Embed file already embedded by kit.sh ../vendor/std/src/http/download.sh
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
# }}} source git/fetch.sh
# {{{ source git/sum.sh
#!/usr/bin/env bash
function git::sum() (
    local dir="${1}"
    cd "${dir}" || return 1
    git log -n1 --format=format:"%H"
)
# }}} source git/sum.sh
# {{{ source git/latest_tag.sh
#!/usr/bin/env bash
function git::latest_tag() (
    local dir="${1}"
    cd "${dir}" || return 1
    git tag -n | sort -rV | head -n 1 | awk '{print $1}'
)
# }}} source git/latest_tag.sh
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

#
# ../vendor/std/src/log/verbose.sh is quoted by ../vendor/std/src/log/is_output.sh
# ../vendor/std/src/http/download.sh is quoted by kit.sh
# ../vendor/std/src/runtime/command_exist.sh is quoted by ../vendor/std/src/crypto/sha256/sum.sh ../vendor/std/src/http/download.sh
# git/fetch.sh is quoted by kit.sh
# git/latest_tag.sh is quoted by kit.sh
# ../vendor/std/src/log/is_output.sh is quoted by ../vendor/std/src/log/info.sh ../vendor/std/src/http/download.sh
# git/sum.sh is quoted by kit.sh
# ../vendor/std/src/runtime/stack_trace.sh is quoted by ../vendor/std/src/log/error.sh
# ../vendor/std/src/log/error.sh is quoted by ../vendor/std/src/crypto/sha256/sum.sh kit.sh ../vendor/std/src/http/download.sh
# ../vendor/std/src/log/info.sh is quoted by kit.sh ../vendor/std/src/http/download.sh git/fetch.sh
# ../vendor/std/src/crypto/sha256/sum.sh is quoted by kit.sh

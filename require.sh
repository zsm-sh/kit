#!/usr/bin/env bash
# {{{ source crypto/sha256/sum.sh
#!/usr/bin/env bash
# {{{ source log/error.sh
#!/usr/bin/env bash
# {{{ source runtime/stack_trace.sh
#!/usr/bin/env bash
function runtime::stack_trace() {
    local i=${1:-0}
    while caller $i; do
        ((i++))
    done | awk '{print  "[" NR "] " $3 ":" $1 " " $2}'
}
# }}} source runtime/stack_trace.sh
# Print error message and stack trace to stderr with timestamp
function log::error() {
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] ERROR ${*}" >&2
    runtime::stack_trace 1 >&2
}
# }}} source log/error.sh
# {{{ source runtime/command_exist.sh
#!/usr/bin/env bash
# Check a command exist
function runtime::command_exist() {
  local command="${1}"
  type "${command}" >/dev/null 2>&1
}
# }}} source runtime/command_exist.sh
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
# }}} source crypto/sha256/sum.sh
# {{{ source log/error.sh
#!/usr/bin/env bash
# {{{ source runtime/stack_trace.sh
#!/usr/bin/env bash
function runtime::stack_trace() {
    local i=${1:-0}
    while caller $i; do
        ((i++))
    done | awk '{print  "[" NR "] " $3 ":" $1 " " $2}'
}
# }}} source runtime/stack_trace.sh
# Print error message and stack trace to stderr with timestamp
function log::error() {
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] ERROR ${*}" >&2
    runtime::stack_trace 1 >&2
}
# }}} source log/error.sh
# {{{ source log/info.sh
#!/usr/bin/env bash
# {{{ source log/is_output.sh
#!/usr/bin/env bash
# {{{ source log/verbose.sh
#!/usr/bin/env bash
# get verbose level
function log::verbose() {
    echo "${LOG_VERBOSE:-0}"
}
# }}} source log/verbose.sh
# whether to output
function log::is_output() {
    local v="${1}"
    if [[ "${v}" -gt "$(log::verbose)" ]]; then
        return 1
    fi
}
# }}} source log/is_output.sh
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
# }}} source log/info.sh
# {{{ source utils/download.sh
#!/usr/bin/env bash
# {{{ source runtime/command_exist.sh
#!/usr/bin/env bash
# Check a command exist
function runtime::command_exist() {
  local command="${1}"
  type "${command}" >/dev/null 2>&1
}
# }}} source runtime/command_exist.sh
# {{{ source log/error.sh
#!/usr/bin/env bash
# {{{ source runtime/stack_trace.sh
#!/usr/bin/env bash
function runtime::stack_trace() {
    local i=${1:-0}
    while caller $i; do
        ((i++))
    done | awk '{print  "[" NR "] " $3 ":" $1 " " $2}'
}
# }}} source runtime/stack_trace.sh
# Print error message and stack trace to stderr with timestamp
function log::error() {
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] ERROR ${*}" >&2
    runtime::stack_trace 1 >&2
}
# }}} source log/error.sh
# {{{ source log/info.sh
#!/usr/bin/env bash
# {{{ source log/is_output.sh
#!/usr/bin/env bash
# {{{ source log/verbose.sh
#!/usr/bin/env bash
# get verbose level
function log::verbose() {
    echo "${LOG_VERBOSE:-0}"
}
# }}} source log/verbose.sh
# whether to output
function log::is_output() {
    local v="${1}"
    if [[ "${v}" -gt "$(log::verbose)" ]]; then
        return 1
    fi
}
# }}} source log/is_output.sh
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
# }}} source log/info.sh
# {{{ source log/is_output.sh
#!/usr/bin/env bash
# {{{ source log/verbose.sh
#!/usr/bin/env bash
# get verbose level
function log::verbose() {
    echo "${LOG_VERBOSE:-0}"
}
# }}} source log/verbose.sh
# whether to output
function log::is_output() {
    local v="${1}"
    if [[ "${v}" -gt "$(log::verbose)" ]]; then
        return 1
    fi
}
# }}} source log/is_output.sh
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
# }}} source utils/download.sh
# {{{ source utils/git_fetch.sh
#!/usr/bin/env bash
# {{{ source log/info.sh
#!/usr/bin/env bash
# {{{ source log/is_output.sh
#!/usr/bin/env bash
# {{{ source log/verbose.sh
#!/usr/bin/env bash
# get verbose level
function log::verbose() {
    echo "${LOG_VERBOSE:-0}"
}
# }}} source log/verbose.sh
# whether to output
function log::is_output() {
    local v="${1}"
    if [[ "${v}" -gt "$(log::verbose)" ]]; then
        return 1
    fi
}
# }}} source log/is_output.sh
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
# }}} source log/info.sh
function utils::git_fetch() (
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
# }}} source utils/git_fetch.sh
# {{{ source utils/git_sum.sh
#!/usr/bin/env bash
function utils::git_sum() (
    local dir="${1}"
    cd "${dir}" || return 1
    git log -n1 --format=format:"%H"
)
# }}} source utils/git_sum.sh
# {{{ source utils/git_latest_tag.sh
#!/usr/bin/env bash
function utils::git_latest_tag() (
    local dir="${1}"
    cd "${dir}" || return 1
    git tag -n | sort -rV | head -n 1 | awk '{print $1}'
)
# }}} source utils/git_latest_tag.sh
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

#
# runtime/command_exist.sh is quoted by crypto/sha256/sum.sh utils/download.sh
# runtime/stack_trace.sh is quoted by log/error.sh log/error.sh log/error.sh
# utils/download.sh is quoted by require.sh
# log/info.sh is quoted by require.sh utils/download.sh utils/git_fetch.sh
# utils/git_fetch.sh is quoted by require.sh
# log/error.sh is quoted by crypto/sha256/sum.sh require.sh utils/download.sh
# crypto/sha256/sum.sh is quoted by require.sh
# log/is_output.sh is quoted by log/info.sh log/info.sh utils/download.sh log/info.sh
# log/verbose.sh is quoted by log/is_output.sh log/is_output.sh log/is_output.sh log/is_output.sh
# utils/git_latest_tag.sh is quoted by require.sh
# utils/git_sum.sh is quoted by require.sh

#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../log/info.sh"

function testing::test() {
    local dir="${1}"
    local failed=()
    local test_dir
    for file in $(find "${dir}" -name '*.test.sh'); do
        test_dir="$(dirname "${file}")"
        test_file="$(basename "${file}")"
        log::info "Running test ${test_file} in ${test_dir}"
        ( cd "${test_dir}" && bash "./${test_file}" )
        if [[ $? -ne 0 ]]; then
            log::info "Test failed ${test_file} in ${test_dir}"
            failed+=("${file}")
        else
            log::info "Test passed ${test_file} in ${test_dir}"
        fi
    done

    if [[ "${#failed[@]}" -ne 0 ]]; then
        log::info "Failed tests:"
        for file in "${failed[@]}"; do
            log::info "  ${file}"
        done
        return 1
    fi
    log::info "All tests passed"
}

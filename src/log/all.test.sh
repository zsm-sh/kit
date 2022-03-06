#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/info.sh"
source "$(dirname "${BASH_SOURCE[0]}")/error.sh"

LOG_VERBOSE=0

function got() {
    log::info VERBOSE=0 V=0

    log::info -v=1 VERBOSE=0 V=1
    log::info -v 1 VERBOSE=0 V=1

    LOG_VERBOSE=1 log::info -v=1 VERBOSE=1 V=1
    LOG_VERBOSE=1 log::info -v 1 VERBOSE=1 V=1

    LOG_VERBOSE=1 log::error VERBOSE=1 V=0
}

function want() {
    local t
    t="$(date +%Y-%m-%dT%H:%M:%S%z)"
    cat <<EOF
[${t}] INFO VERBOSE=0 V=0
[${t}] INFO(1) VERBOSE=1 V=1
[${t}] INFO(1) VERBOSE=1 V=1
[${t}] ERROR VERBOSE=1 V=0
[1] ./all.test.sh:17 got
[2] ./all.test.sh:35 main
EOF
}


# If time is in the critical point, there is a probability fail, so we try again
diff <(want) <(got 2>&1) || diff <(want) <(got 2>&1) >/dev/null 2>&1



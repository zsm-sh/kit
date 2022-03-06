#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/sum.sh"

function got() {
    crypto::sha256::sum ../../../LICENSE
}

function want() {
    cat <<EOF
a9aa16248ab452deff543ae82005a871ce93fcd4129f516915c7bbc7ddc78ec6
EOF
}

diff <(want) <(got)

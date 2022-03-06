#!/usr/bin/env bash

function runtime::stack_trace() {
    local i=${1:-0}
    while caller $i; do
        ((i++))
    done | awk '{print  "[" NR "] " $3 ":" $1 " " $2}'
}

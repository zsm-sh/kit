#!/usr/bin/env bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"

"${CURRENT_DIR}/kit.sh" "${CURRENT_DIR}/../vendor.kit"

"${CURRENT_DIR}/../vendor/bin/embed.sh" --once=y "${CURRENT_DIR}/kit.sh" > "${CURRENT_DIR}/../kit.sh"
chmod +x "${CURRENT_DIR}/../kit.sh"

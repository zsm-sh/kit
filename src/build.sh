#!/usr/bin/env bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"

"${CURRENT_DIR}/kit.sh" "${CURRENT_DIR}/../vendor.kit"

bash "${CURRENT_DIR}/../vendor/embed/embed.sh" --once=y "${CURRENT_DIR}/kit.sh" > "${CURRENT_DIR}/../kit.sh"

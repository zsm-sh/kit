#!/usr/bin/env bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"

"${CURRENT_DIR}/require.sh" "${CURRENT_DIR}/../require.sum"

bash "${CURRENT_DIR}/../vendor/embed/embed.sh" --once=y "${CURRENT_DIR}/require.sh" > "${CURRENT_DIR}/../require.sh"

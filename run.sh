#!/bin/bash

# shellcheck disable=SC2155

set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly SPOOL_DIR="$SCRIPT_DIR/spool"


main() {
    if ! [ -d "$SPOOL_DIR" ]; then
        echo "misisng spool dir at $SPOOL_DIR" >&2
        exit 1
    fi

    if ! docker plugin ls | grep -q 'rclone' &>/dev/null; then
        echo "installing docker plugin rclone"
        local rclone_config="$SCRIPT_DIR/config/rclone"
        local rclone_cache="$SPOOL_DIR/cache/rclone"

        mkdir -p "$rclone_cache"

        docker plugin install itstoggle/docker-volume-rclone_rd:amd64 \
            args="-v" --alias rclone --grant-all-permissions \
            "config=$rclone_config" "cache=$rclone_cache"
    else
        echo "docker plugin rclone already installed"
    fi

}

main "$@"

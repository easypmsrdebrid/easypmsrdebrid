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

    if [ -f "$SCRIPT_DIR/.env" ]; then
        # shellcheck disable=SC1091
        source "$SCRIPT_DIR/.env"
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

    if ! docker volume ls | grep -q 'realdebrid' &>/dev/null; then
        echo "installing docker volume realdebrid"

        if [ -z "$RDEBRID_TOKEN" ]; then
            echo "missing RDEBRID_TOKEN environment variable" >&2
            exit 1
        fi

        docker volume create realdebrid -d rclone -o type=realdebrid \
            -o "realdebrid-api_key=$RDEBRID_TOKEN" -o allow-other=true \
            -o dir-cache-time=10s
    else
        echo "docker volume realdebrid already mounted"
    fi

}

main "$@"

#!/usr/bin/env bash

set -euo pipefail

export CONTAINER=swayvnc-firefox
readonly CONTAINER
export LISTEN_ADDRESS="127.0.0.1" #"[::1]"
readonly LISTEN_ADDRESS
export VERBOSE=1
readonly VERBOSE
SCRIPT_NAME=$(basename $0)
readonly SCRIPT_NAME


log() {
    if (( 1=="${VERBOSE}" )); then
        echo "$@" >&2
    fi

    logger -p user.notice -t ${SCRIPT_NAME} "$@"
}

error() {
    echo "$@" >&2
    logger -p user.error -t ${SCRIPT_NAME} "$@"
}

if [[ -z $(which podman) ]]; then
    if [[ -z $(which docker) ]]; then
        error "Could not find container executor."
        error "Install either podman or docker"
        exit 1
    else
        executor=docker
        log "Using ${executor} to run ${CONTAINER}"
    fi
else
    executor=podman
    log "Using ${executor} to run ${CONTAINER}"
fi

${executor} run --name ${CONTAINER} \
                -p${LISTEN_ADDRESS}:5910:5910 \
                -p${LISTEN_ADDRESS}:7023:7023 \
                -v Downloads:/home/firefox-user/Downloads \
                --privileged \
                --rm \
                ${CONTAINER}

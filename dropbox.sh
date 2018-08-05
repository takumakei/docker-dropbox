#!/usr/bin/env bash

set -eu

DROPBOX_IMAGE="${DROPBOX_IMAGE:-takumakei/dropbox:latest}"
DROPBOX_NAME="${DROPBOX_NAME:-}"
DROPBOX_SYNC="${DROPBOX_SYNC:-$HOME/Dropbox}"
DROPBOX_CONF="${DROPBOX_CONF:-$HOME/.dropbox}"

dropbox_help() {
  local name
  if [[ -z "$DROPBOX_NAME" ]]; then
    name="mandatory - not defined"
  else
    name="$DROPBOX_NAME"
  fi

  if [[ -z "$DROPBOX_IMAGE" ]]; then
    echo "ERROR: DROPBOX_IMAGE environment variable is empty" 1>&2
    exit 1
  fi

  cat <<EOF
Usage: dropbox.sh [command] [options...]

  Script for the container of Dropbox client for Linux

environments:
  DROPBOX_IMAGE  docker image name   ($DROPBOX_IMAGE)
  DROPBOX_NAME   container name      ($name)
  DROPBOX_SYNC   directory to sync   ($DROPBOX_SYNC)
  DROPBOX_CONF   directory to config ($DROPBOX_CONF)

commands:
  u, up      docker run ${DROPBOX_IMAGE}
  s, status  dropbox.py status
  d, down    dropbox.py stop
  c, cli     dropbox.py [options...]
  l, logs    docker logs ${DROPBOX_NAME}
  e, exec    docker exec ${DROPBOX_NAME} [options...]
  S, STOP    docker stop ${DROPBOX_NAME}
  K, KILL    docker kill ${DROPBOX_NAME}
  R, RM      docker rm   ${DROPBOX_NAME}
EOF
}

main() {
  if [[ $# -eq 0 ]]; then
    dropbox_help
    return
  fi

  if [[ -z "$DROPBOX_NAME" ]]; then
    echo "ERROR: DROPBOX_NAME environment variable is not defined" 1>&2
    exit 1
  fi

  local cmd="$1"
  shift

  case "$cmd" in
    u|up)
      dropbox_up "$@"
      ;;
    s|status)
      dropbox_status "$@"
      ;;
    d|down)
      dropbox_down "$@"
      ;;
    l|logs)
      dropbox_logs "$@"
      ;;
    e|exec)
      dropbox_exec "$@"
      ;;
    S|STOP)
      dropbox_stop "$@"
      ;;
    K|KILL)
      dropbox_kill "$@"
      ;;
    R|RM)
      dropbox_rm "$@"
      ;;
    c|cli)
      dropbox_cli "$@"
      ;;
    h|help|-h|--help)
      dropbox_help "$@"
      ;;
    *)
      echo "ERROR: unknown command '$cmd'" 1>&2
      dropbox_help "$@"
      exit 1
      ;;
  esac
}

dropbox_up() {
  if docker inspect "${DROPBOX_NAME}" --format '{{.ID}}' >/dev/null 2>&1; then
    run \
    docker start "$DROPBOX_NAME"
    return
  fi

  run \
  docker run --name "$DROPBOX_NAME"                       \
             --detach                                     \
             --restart=on-failure                         \
             --memory=256m                                \
             --volume="${DROPBOX_SYNC}":/dropbox/Dropbox  \
             --volume="${DROPBOX_CONF}":/dropbox/.dropbox \
             ${DROPBOX_IMAGE}
}

dropbox_status() {
  run docker exec -it "$DROPBOX_NAME" dropbox.py status
}

dropbox_down() {
  run docker exec -it "$DROPBOX_NAME" dropbox.py stop
}

dropbox_logs() {
  run docker logs "$@" "$DROPBOX_NAME"
}

dropbox_exec() {
  run docker exec "$DROPBOX_NAME" "$@"
}

dropbox_stop() {
  run docker stop "$DROPBOX_NAME"
}

dropbox_kill() {
  run docker kill "$DROPBOX_NAME"
}

dropbox_rm() {
  run docker rm "$DROPBOX_NAME"
}

dropbox_cli() {
  run docker exec -it "$DROPBOX_NAME" dropbox.py "$@"
}

run() {
  echo "==> $*"
  "$@"
}

main "$@"

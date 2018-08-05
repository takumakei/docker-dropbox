#!/usr/bin/env bash

set -eu

main() {
  local mine latest
  mine="$(cat Dockerfile | extract_version)"
  latest="$(curl --head -sS 'https://www.dropbox.com/download?plat=lnx.x86_64' | extract_version)"

  if [[ "$mine" = "$latest" ]]; then
    echo "up to date (version:$latest)"
  else
    echo "updated (latest:$latest != $mine:Dockerfile)"
    exit 1
  fi
}

extract_version() {
  sed -e '/dbx-releng\/client\/dropbox-lnx/!d' -e 's/^.*x86_64-\(.*\)\.tar\.gz.*/\1/'
}

main "$@"

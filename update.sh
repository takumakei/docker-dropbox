#!/usr/bin/env bash

set -eu

URL="https://www.dropbox.com/download?plat=lnx.x86_64"

main() {
  local url version

  cd "$(dirname "$BASH_SOURCE")"

  url="$(curl -sS --head "$URL" | sed -e '/^Location:/!d' -e 's/^Location: //' -e 's///g')"
  print_dockerfile "$url" > Dockerfile

  version="$(echo "$url" | sed -e 's/^.*x86_64-\(.*\)\.tar\.gz/\1/')"
  echo "$version"
  git status --short
}

print_dockerfile() {
  local url="$1"

  cat <<EOF
FROM debian:stretch-slim AS wget

RUN apt-get update \\
 && apt-get install -y --no-install-recommends ca-certificates wget \\
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /dropboxd \\
 && wget -q -O - "${url}" | tar xzf - -C /dropboxd --strip 1 \\
 && wget -q -O /usr/bin/dropbox.py "https://www.dropbox.com/download?dl=packages/dropbox.py" \\
 && chmod +x /usr/bin/dropbox.py

FROM debian:stretch-slim

RUN apt-get update \\
 && apt-get install -y --no-install-recommends ca-certificates python \\
 && rm -rf /var/lib/apt/lists/*

COPY --from=wget /dropboxd /dropboxd
COPY --from=wget /usr/bin/dropbox.py /usr/bin/dropbox.py
COPY assets/usercustomize.py /dropbox/.local/lib/python2.7/site-packages/usercustomize.py

RUN mkdir -p /dropbox/Dropbox
ENV HOME /dropbox
WORKDIR /dropbox/Dropbox
CMD ["/dropboxd/dropboxd"]
EOF

}

main "$@"

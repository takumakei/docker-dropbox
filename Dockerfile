FROM debian:stretch-slim AS wget

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates wget \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /dropboxd \
 && wget -q -O - "https://clientupdates.dropboxstatic.com/dbx-releng/client/dropbox-lnx.x86_64-53.4.67.tar.gz" | tar xzf - -C /dropboxd --strip 1 \
 && wget -q -O /usr/bin/dropbox.py "https://www.dropbox.com/download?dl=packages/dropbox.py" \
 && chmod +x /usr/bin/dropbox.py

FROM debian:stretch-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates python \
 && rm -rf /var/lib/apt/lists/*

COPY --from=wget /dropboxd /dropboxd
COPY --from=wget /usr/bin/dropbox.py /usr/bin/dropbox.py

VOLUME /dropbox
ENV HOME /dropbox
WORKDIR /dropbox
CMD ["/dropboxd/dropboxd"]

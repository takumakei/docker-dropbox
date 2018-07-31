FROM debian:stretch-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates python wget \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /dropboxd \
 && wget -O - "https://clientupdates.dropboxstatic.com/dbx-releng/client/dropbox-lnx.x86_64-53.4.67.tar.gz" | tar xzf - -C /dropboxd --strip 1

RUN wget -O /usr/bin/dropbox.py "https://www.dropbox.com/download?dl=packages/dropbox.py" \
 && chmod +x /usr/bin/dropbox.py

VOLUME /dropbox
ENV HOME /dropbox
WORKDIR /dropbox
CMD ["/dropboxd/dropboxd"]

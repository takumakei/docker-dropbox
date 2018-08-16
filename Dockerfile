FROM debian:stretch-slim AS wget

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates wget \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /dropboxd \
 && wget -q -O - "https://clientupdates.dropboxstatic.com/dbx-releng/client/dropbox-lnx.x86_64-55.4.171.tar.gz" | tar xzf - -C /dropboxd --strip 1 \
 && wget -q -O /usr/bin/dropbox.py "https://www.dropbox.com/download?dl=packages/dropbox.py" \
 && chmod +x /usr/bin/dropbox.py

FROM debian:stretch-slim

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates python \
 && rm -rf /var/lib/apt/lists/*

COPY --from=wget /dropboxd /dropboxd
COPY --from=wget /usr/bin/dropbox.py /usr/bin/dropbox.py
COPY assets/usercustomize.py /dropbox/.local/lib/python2.7/site-packages/usercustomize.py

RUN mkdir -p /dropbox/Dropbox
ENV HOME /dropbox
WORKDIR /dropbox/Dropbox
CMD ["/dropboxd/dropboxd"]

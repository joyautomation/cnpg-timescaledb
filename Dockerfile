ARG PG_MAJOR=17
ARG BASE_TAG=${PG_MAJOR}-bookworm

FROM ghcr.io/cloudnative-pg/postgresql:${BASE_TAG}

ARG PG_MAJOR=17
ARG TIMESCALE_VERSION=2.25

USER root

RUN set -xe; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        lsb-release; \
    curl -fsSL https://packagecloud.io/timescale/timescaledb/gpgkey \
        | gpg --dearmor -o /usr/share/keyrings/timescale.gpg; \
    DEBIAN_CODENAME="$(lsb_release -cs)"; \
    echo "deb [signed-by=/usr/share/keyrings/timescale.gpg] https://packagecloud.io/timescale/timescaledb/debian/ ${DEBIAN_CODENAME} main" \
        > /etc/apt/sources.list.d/timescaledb.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        "timescaledb-2-postgresql-${PG_MAJOR}=${TIMESCALE_VERSION}.*" \
        "timescaledb-2-loader-postgresql-${PG_MAJOR}=${TIMESCALE_VERSION}.*"; \
    apt-get purge -y --auto-remove curl gnupg lsb-release; \
    rm -rf /var/lib/apt/lists/* /tmp/*

USER 26

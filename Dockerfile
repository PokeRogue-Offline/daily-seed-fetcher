FROM alpine:3.20

RUN apk add --no-cache bash curl

# supercronic - lightweight cron for containers
ARG SUPERCRONIC_VERSION=v0.2.33
ARG SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64
RUN curl -fsSLo /usr/local/bin/supercronic "$SUPERCRONIC_URL" \
    && chmod +x /usr/local/bin/supercronic

COPY lib.sh /usr/local/bin/lib.sh
COPY getSeed.sh /usr/local/bin/getSeed.sh
RUN chmod +x /usr/local/bin/getSeed.sh

COPY crontab /etc/crontabs/root

VOLUME /output

ENTRYPOINT ["/usr/local/bin/supercronic", "/etc/crontabs/root"]

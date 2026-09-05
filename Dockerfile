FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    openfortivpn \
    iptables \
    ppp \
    ca-certificates \
    iproute2 \
    dnsmasq \
    procps \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /entrypoint.sh /healthcheck.sh

ENTRYPOINT ["/entrypoint.sh"]
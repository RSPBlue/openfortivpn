#!/bin/bash
set -e

# 1. Verify openfortivpn process is alive
pgrep openfortivpn >/dev/null 2>&1 || exit 1

# 2. Verify ppp0 interface is up and has an assigned IP address
ip addr show dev ppp0 2>/dev/null | grep -q "inet " || exit 1

# 3. Verify internal connectivity if HEALTHCHECK_TARGET is set
if [ -n "${HEALTHCHECK_TARGET}" ]; then
    ping -c 1 -W 3 "${HEALTHCHECK_TARGET}" >/dev/null 2>&1 || exit 1
fi

exit 0
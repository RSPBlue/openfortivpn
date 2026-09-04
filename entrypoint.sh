#!/bin/bash
set -e

# Create /dev/ppp character device if missing
if [ ! -c /dev/ppp ]; then
    mkdir -p /dev
    mknod /dev/ppp c 108 0
    chmod 600 /dev/ppp
fi

# Enable NAT masquerading
iptables -t nat -A POSTROUTING -o ppp+ -j MASQUERADE || true

# Execute openfortivpn
exec openfortivpn "${VPNADDR}" \
  --username="${VPNUSER}" \
  --password="${VPNPASS}" \
  ${TRUSTED_CERT:+--trusted-cert="${TRUSTED_CERT}"} \
  ${EXTRA_ARGS}
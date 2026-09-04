#!/bin/sh
set -e

# Set up NAT masquerading so other containers can route traffic through the tunnel
iptables -t nat -A POSTROUTING -o ppp+ -j MASQUERADE || true

# Launch openfortivpn
exec openfortivpn ${VPNADDR} \
  --username="${VPNUSER}" \
  --password="${VPNPASS}" \
  ${TRUSTED_CERT:+--trusted-cert="${TRUSTED_CERT}"} \
  ${EXTRA_ARGS}
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

# Forward .unifor.br queries directly to the VPN DNS, and everything else to 1.1.1.1
dnsmasq \
  --listen-address=172.28.0.2 \
  --bind-interfaces \
  --server=/unifor.br/172.29.0.3 \
  --server=1.1.1.1 \
  --user=root &

# Launch openfortivpn
exec openfortivpn "${VPNADDR}" \
  --username="${VPNUSER}" \
  --password="${VPNPASS}" \
  ${TRUSTED_CERT:+--trusted-cert="${TRUSTED_CERT}"} \
  ${EXTRA_ARGS}
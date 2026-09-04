#!/bin/bash
set -e

# Create /dev/ppp character device if missing
if [ ! -c /dev/ppp ]; then
    mkdir -p /dev
    mknod /dev/ppp c 108 0
    chmod 600 /dev/ppp
fi

# Enable NAT masquerading for all VPN traffic passing through ppp
iptables -t nat -A POSTROUTING -o ppp+ -j MASQUERADE || true

# Start dnsmasq in the background listening on the container's static IP
dnsmasq \
  --listen-address=172.28.0.2 \
  --bind-interfaces \
  --resolv-file=/etc/resolv.conf \
  --poll \
  --user=root &

# Launch openfortivpn
exec openfortivpn "${VPNADDR}" \
  --username="${VPNUSER}" \
  --password="${VPNPASS}" \
  ${TRUSTED_CERT:+--trusted-cert="${TRUSTED_CERT}"} \
  ${EXTRA_ARGS}
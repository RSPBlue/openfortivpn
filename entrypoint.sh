#!/bin/bash
set -e

# Create /dev/ppp device if missing
if [ ! -c /dev/ppp ]; then
    mkdir -p /dev
    mknod /dev/ppp c 108 0
    chmod 600 /dev/ppp
fi

# Allow forwarding between docker network (eth0) and VPN tunnel (ppp+)
iptables -A FORWARD -i eth0 -o ppp+ -j ACCEPT
iptables -A FORWARD -i ppp+ -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -o ppp+ -j MASQUERADE

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
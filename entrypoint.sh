#!/bin/bash
set -e

# Create /dev/ppp if missing
if [ ! -c /dev/ppp ]; then
    mkdir -p /dev
    mknod /dev/ppp c 108 0
    chmod 600 /dev/ppp
fi

# 1. Packet Forwarding Rules
iptables -A FORWARD -i eth0 -o ppp+ -j ACCEPT
iptables -A FORWARD -i ppp+ -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

# 2. NAT Masquerading for the VPN interface
iptables -t nat -A POSTROUTING -o ppp+ -j MASQUERADE

# 3. MSS Clamping (prevents packet drops from MTU mismatch between Docker & PPP)
iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# 4. Start dnsmasq
dnsmasq \
  --listen-address=172.28.0.2 \
  --bind-interfaces \
  --server=/unifor.br/172.29.0.3 \
  --server=1.1.1.1 \
  --user=root &

# 5. Launch openfortivpn
exec openfortivpn "${VPNADDR}" \
  --username="${VPNUSER}" \
  --password="${VPNPASS}" \
  ${TRUSTED_CERT:+--trusted-cert="${TRUSTED_CERT}"} \
  ${EXTRA_ARGS}
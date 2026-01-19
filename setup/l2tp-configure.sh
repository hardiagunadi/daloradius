#!/usr/bin/env bash
set -euo pipefail

# Edit these values before running.
SERVER_IP="157.15.124.32"
IPSEC_PSK="change-me"
L2TP_POOL_RANGE="10.10.10.2-10.10.10.254"
L2TP_LOCAL_IP="10.10.10.1"
RADIUS_SERVER_IP="10.10.10.1"
RADIUS_SECRET="change-me"
RADIUS_AUTH_PORT="1812"
RADIUS_ACCT_PORT="1813"

install -d -m 0755 /etc/ppp/radius

cat > /etc/ipsec.conf <<EOF
config setup
    uniqueids=no

conn l2tp-psk
    keyexchange=ikev1
    authby=psk
    type=transport
    left=${SERVER_IP}
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
    auto=add
EOF

cat > /etc/ipsec.secrets <<EOF
${SERVER_IP} %any : PSK "${IPSEC_PSK}"
EOF

cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[global]
port = 1701

[lns default]
ip range = ${L2TP_POOL_RANGE}
local ip = ${L2TP_LOCAL_IP}
require chap = yes
refuse pap = yes
require authentication = yes
name = l2tpd
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

cat > /etc/ppp/options.xl2tpd <<EOF
require-mschap-v2
refuse-pap
refuse-chap
refuse-mschap
ms-dns 8.8.8.8
ms-dns 1.1.1.1
mtu 1410
mru 1410
lock
auth
proxyarp
lcp-echo-interval 30
lcp-echo-failure 4
plugin radius.so
radius-config-file /etc/ppp/radius/radius.conf
EOF

cat > /etc/ppp/radius/servers <<EOF
${RADIUS_SERVER_IP} ${RADIUS_SECRET}
EOF

cat > /etc/ppp/radius/radius.conf <<EOF
authserver ${RADIUS_SERVER_IP}
acctserver ${RADIUS_SERVER_IP}
radius_timeout 10
radius_retries 3
EOF

cat > /etc/sysctl.d/99-l2tp.conf <<EOF
net.ipv4.ip_forward=1
EOF
sysctl --system

systemctl restart strongswan-starter || systemctl restart strongswan
systemctl restart xl2tpd

echo "L2TP server configured. Open UDP 500/4500/1701 and RADIUS ports ${RADIUS_AUTH_PORT}/${RADIUS_ACCT_PORT}."

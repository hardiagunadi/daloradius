#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y strongswan xl2tpd ppp freeradius-utils

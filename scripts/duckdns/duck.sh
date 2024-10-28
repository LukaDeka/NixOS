#!/usr/bin/env

TOKEN=$(cat ~/env/duckdns/token.txt)

DOMAIN="lukadeka"
DUCKDNS_URL="https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&ip="

# Update DuckDNS IP and log the output
curl -k -o /home/luka/nixos/scripts/duckdns/duck.log -K - <<< "url=${DUCKDNS_URL}"

# Log date and time
date +'%d/%m/%y %H:%M' >> /home/luka/nixos/scripts/duckdns/duck.txt


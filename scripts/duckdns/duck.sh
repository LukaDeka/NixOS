#! /usr/bin/env nix-shell

domain="${VAR_DDNS%%.*}"
token=$(< /etc/env/duckdns/token)
logfile_path="${VAR_HOME_DIR}/nixos/scripts/duckdns/duck.log"

duckdns_url="https://www.duckdns.org/update?domains=${domain}&token=${token}&ip="

# Update DuckDNS IP
status=$(curl ${duckdns_url})

# Log timestamp and status code (OK for success, KO for failure)
echo "[$(date +'%d/%m/%y %H:%M')] ${status} ">> ${logfile_path}


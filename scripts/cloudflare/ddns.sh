#!/bin/bash

# A list of domain names to be synced
declare -a domains=(
  "${VAR_DOMAIN}"
  "nextcloud.${VAR_DOMAIN}"
  "collabora.${VAR_DOMAIN}"
)

# Specify which DNS records should point to Cloudflare's
# proxies and which directly to your public IP
declare -A is_proxied=(
  ["${VAR_DOMAIN}"]="false"
  ["ddns.${VAR_DOMAIN}"]="false"
  ["nextcloud.${VAR_DOMAIN}"]="false"
  ["collabora.${VAR_DOMAIN}"]="false"
)

ttl=300 # Only applies to non-proxied domains

logfile_path="${VAR_HOME_DIR}/nixos/scripts/cloudflare/ddns.log"

auth_email="${VAR_EMAIL}" # The email used to login 'https://dash.cloudflare.com'
auth_method="global"      # Set to "global" for Global API Key or "token" for Scoped API Token

# Your API Token or Global API Key
auth_key="$(< /etc/env/cloudflare/auth_key)"

# Can be found in the "Overview" tab of your domain
zone_identifier="$(< /etc/env/cloudflare/zone_identifier)"



echo "[$(date +'%d/%m/%y %H:%M')] Running script" >> ${logfile_path}

################################################################################
# Check if we have a public IP
ipv4_regex='([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])'
ip=$(curl -s -4 https://cloudflare.com/cdn-cgi/trace | grep -E '^ip'); ret=$?
if [[ ! $ret == 0 ]]; then # In the case that Cloudflare failed to return an IP
    # Attempt to get the IP from other websites
    ip=$(curl -s https://api.ipify.org || curl -s https://ipv4.icanhazip.com)
else
    # Extract just the IP from the IP line from Cloudflare
    ip=$(echo "$ip" | sed -E "s/^ip=($ipv4_regex)$/\1/")
fi

# Use regex to check for proper IPv4 format
if [[ ! $ip =~ ^$ipv4_regex$ ]]; then
    echo "DDNS Updater: Failed to find a valid IP" >&2
    echo "[$(date +'%d/%m/%y %H:%M')] Failed to find a valid IP. Got: ${ip}" >> ${logfile_path}
    exit 2
fi

# Check and set the proper auth header
if [[ "${auth_method}" == "global" ]]; then
  auth_header="X-Auth-Key:"
else
  auth_header="Authorization: Bearer"
fi


# Iterate through domain names
for record_name in "${domains[@]}"; do

  # Seek for the A record
  record=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A&name=$record_name" \
    -H "X-Auth-Email: $auth_email" \
    -H "$auth_header $auth_key" \
    -H "Content-Type: application/json")

  # Check if the domain has an A record
  if [[ $record == *"\"count\":0"* ]]; then
    echo "DDNS Updater: Record \"${record_name}\" does not exist, perhaps create one first?" >&2
    echo "[$(date +'%d/%m/%y %H:%M')] Record \"${record_name}\" does not exist, perhaps create one first?" >> ${logfile_path}
    exit 1
  fi

  # Get existing IP
  old_ip=$(echo "$record" | sed -E 's/.*"content":"(([0-9]{1,3}\.){3}[0-9]{1,3})".*/\1/')
  # Compare if they're the same
  if [[ $ip == "$old_ip" ]]; then
    exit 0
  fi

  # Set the record identifier from result
  record_identifier=$(echo "$record" | sed -E 's/.*"id":"([A-Za-z0-9_]+)".*/\1/')

  proxy="${is_proxied[$record_name]}"

  # Update the IP using the API
  update=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
    -H "X-Auth-Email: $auth_email" \
    -H "$auth_header $auth_key" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"$record_name\",\"content\":\"$ip\",\"ttl\":$ttl,\"proxied\":${proxy}}")

  case "$update" in
  *"\"success\":false"*)
    echo "DDNS Updater: Failed updating record: \"${record_name}\"" >&2
    echo "[$(date +'%d/%m/%y %H:%M')] Failed updating record: \"${record_name}\"" >> ${logfile_path}
    exit -1;;
  *)
    echo "[$(date +'%d/%m/%y %H:%M')] Successfully updated record: \"${record_name}\"" >> ${logfile_path};;
  esac

done


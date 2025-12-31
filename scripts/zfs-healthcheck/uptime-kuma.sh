#! /bin/sh
set -euo pipefail
set -x

push_token=$(< /etc/env/zfs/push-token);

start_time=$(date -u +%s%3N)
health=$(zpool list -H -o health)

status="up"

echo "$health" | while IFS= read -r line; do
  if [ "$line" != "ONLINE" ]; then
    status="down"
    break
  fi
done

end_time=$(date -u +%s%3N)
duration=$(("$end_time" - "$start_time"))

msg=$(printf '%s' "$health" | tr '\n' ',' | tr -d "'" | jq -sRr @uri)
url="http://$VAR_IP:4000/api/push/$push_token?ping=$duration&status=$status&msg='$msg'"

output=$(curl --fail --no-progress-meter --retry 1 $url 2>&1)
if [ $? -ne 0 ]; then
    echo "Ping failed: $output" >&2
fi


#! /bin/sh

push_token=$(< /etc/env/zfs/push-token);

start_time=$(date -u +%s%3N)
health=$(zpool list -H -o health)

status="up"
IFS=$'\n'
while IFS= read -r line; do
    if [ "$health" != "ONLINE" ]; then
        status="down"
    fi
done <<< "$health"

end_time=$(date -u +%s%3N)
duration=$(("$end_time" - "$start_time"))

output=$(curl --fail --no-progress-meter --retry 1 "http://$VAR_IP:4000/api/push/$push_token?ping=$duration&status=$status&msg=$health" 2>&1)
if [ $? -ne 0 ]; then
    echo "Ping failed: $output" >&2
fi


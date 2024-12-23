#! /usr/bin/env nix-shell

push_token=$(< /etc/env/zfs/push-token);
pool="zfs0";

start_time=$(date -u +%s%3N)
health=$(zpool list -H -o health $pool)

status="down"
if [ "$health" = "ONLINE" ]; then
    status="up"
fi

end_time=$(date -u +%s%3N)
duration=$(("$end_time" - "$start_time"))

output=$(curl --fail --no-progress-meter --retry 1 "http://$VAR_IP:4000/api/push/$push_token?ping=$duration&status=$status&msg=$pool%3A%20$health" 2>&1)
if [ $? -ne 0 ]; then
    echo "Ping failed: $output" >&2
fi


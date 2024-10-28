#!/usr/bin/env
echo url="https://www.duckdns.org/update?domains=lukadeka&token=6fb54327-8df2-4fca-b468-937598c1699b&ip=" | curl -k -o /home/luka/nixos/scripts/duckdns/duck.log -K - && date +'%d/%m/%y %H:%M' >> ./home/luka/nixos/scripts/duckdns/duck.txt


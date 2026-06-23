# Second Tailscale instance in userspace mode, exposing a SOCKS5 proxy
# exclusively for qbittorrent. Primary Tailscale is unaffected.
#
# SETUP (run once after first deploy):
#   1. Authenticate:
#        sudo tailscale --socket=/run/tailscale-qbittorrent/tailscaled.sock up \
#          --exit-node=<exit-node-ip> \
#          --exit-node-allow-lan-access=true \
#          --hostname=conway-qbt
#
#   2. Approve the new node at https://login.tailscale.com/admin/machines
#
#   3. Verify:
#        curl --socks5 127.0.0.1:1055 https://ipinfo.io
#      Should show your exit node's IP, not conway's.

{ pkgs, ... }:

{
  systemd.services.tailscaled-qbittorrent = {
    description = "Tailscale (qbittorrent exit node proxy)";
    after = [ "network-pre.target" "tailscaled.service" ];
    wants = [ "network-pre.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      # systemd creates /run/tailscale-qbittorrent and /var/lib/tailscale-qbittorrent
      RuntimeDirectory = "tailscale-qbittorrent";
      StateDirectory = "tailscale-qbittorrent";
      RuntimeDirectoryMode = "0750";

      ExecStart = ''
        ${pkgs.tailscale}/bin/tailscaled \
          --tun=userspace-networking \
          --socks5-server=0.0.0.0:1055 \
          --outbound-http-proxy-listen=0.0.0.0:1056 \
          --statedir=/var/lib/tailscale-qbittorrent \
          --socket=/run/tailscale-qbittorrent/tailscaled.sock \
          --port=41642
      '';
      # After tailscaled starts, configure the exit node and flags persistently.
      # This writes into the state dir so it survives reboots without re-running
      # the manual `tailscale up` command.
      ExecStartPost = ''
        ${pkgs.tailscale}/bin/tailscale \
          --socket=/run/tailscale-qbittorrent/tailscaled.sock \
          up \
          --accept-routes \
          --exit-node=100.125.50.21 \
          --exit-node-allow-lan-access \
          --hostname=conway-qbt
      '';
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = true;
    };
  };
}

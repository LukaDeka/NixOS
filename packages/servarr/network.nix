{ pkgs, ... }:

# Isolated bridge network for all servarr containers.
# Subnet: 10.89.1.0/24, gateway: 10.89.1.1 (host bridge IP).

{
  # Killswitch for qbittorrent containers (10.89.1.100 = bridge IP, 100.97.148.111 = Tailscale IP).
  # When the exit node is up, torrent traffic goes via tailscale-exit → WireGuard, exiting the
  # container as 10.89.1.100 (UDP). When the exit node is down, qBittorrent falls back to eth0
  # and appears on FORWARD with src 100.97.148.111 — that must be dropped unconditionally.
  networking.nftables.tables.servarr-killswitch = {
    family = "inet";
    content = ''
      chain qbt-killswitch {
        type filter hook forward priority -100;
        # Tailscale daemon: WireGuard (UDP) and DERP relay (TCP 443) use the bridge IP
        ip saddr 10.89.1.100 meta l4proto udp accept
        ip saddr 10.89.1.100 tcp dport 443 ct state new accept
        ip saddr 10.89.1.100 ct state established,related accept
        ip saddr 10.89.1.100 ct state new drop
        # qBittorrent's Tailscale IP — only appears on FORWARD when exit node is down
        # (routing falls back to eth0). Drop everything: this is the VPN leak guard.
        ip saddr 100.97.148.111 drop
      }
    '';
  };

  systemd.services.podman-network-servarr = {
    description = "Podman bridge network for servarr containers";
    after = [ "network.target" ];
    before = [
      "podman-tailscale-qbt.service"
      "podman-qbittorrent.service"
      "podman-prowlarr.service"
      "podman-radarr.service"
      "podman-sonarr.service"
      "podman-lidarr.service"
      "podman-bazarr.service"
      "podman-jellyseerr.service"
      "podman-flaresolverr.service"
    ];
    wantedBy = [
      "multi-user.target"
      "podman-tailscale-qbt.service"
      "podman-qbittorrent.service"
      "podman-prowlarr.service"
      "podman-radarr.service"
      "podman-sonarr.service"
      "podman-lidarr.service"
      "podman-bazarr.service"
      "podman-jellyseerr.service"
      "podman-flaresolverr.service"
    ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    path = [ pkgs.podman ];
    script = ''
      podman network inspect servarr >/dev/null 2>&1 && exit 0
      podman network create \
        --driver bridge \
        --subnet 10.89.1.0/24 \
        --gateway 10.89.1.1 \
        --opt com.docker.network.bridge.name=servarr-br \
        --internal=false \
        servarr
    '';
  };
}

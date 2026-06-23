{ pkgs, ... }:

# Isolated bridge network for all servarr containers.
# Subnet: 10.89.1.0/24, gateway: 10.89.1.1 (host bridge IP).
# Containers on this network can resolve each other by container name.
# The host (10.89.1.1) exposes the Tailscale SOCKS5 proxy on port 1055.

{
  systemd.services.podman-network-servarr = {
    description = "Podman bridge network for servarr containers";
    after = [ "network.target" ];
    before = [
      "podman-qbittorrent.service"
      "podman-prowlarr.service"
      "podman-radarr.service"
      "podman-sonarr.service"
      "podman-lidarr.service"
      "podman-bazarr.service"
      "podman-jellyseerr.service"
    ];
    wantedBy = [
      "multi-user.target"
      "podman-qbittorrent.service"
      "podman-prowlarr.service"
      "podman-radarr.service"
      "podman-sonarr.service"
      "podman-lidarr.service"
      "podman-bazarr.service"
      "podman-jellyseerr.service"
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

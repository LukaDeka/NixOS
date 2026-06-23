{ pkgs, ... }:

{
  imports = [
    ./network.nix
    ./qbittorrent.nix
    ./tailscale-qbittorrent.nix
    ./prowlarr.nix
    ./radarr.nix
    ./sonarr.nix
    ./lidarr.nix
    ./bazarr.nix
    ./jellyseerr.nix
  ];

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  # Dedicated system user — PUID/PGID 994 used inside all containers
  users.users.servarr = {
    isSystemUser = true;
    uid = 994;
    group = "servarr";
  };
  users.groups.servarr = { gid = 994; };

  # Config, media, and env file directories + empty placeholder env files.
  # "f" creates an empty file if it doesn't exist (preserves any existing content).
  # Runs via systemd-tmpfiles before any container services start.
  systemd.tmpfiles.rules = [
    "d /var/lib/servarr                  0755 servarr servarr -"
    "d /var/lib/servarr/qbittorrent      0755 servarr servarr -"
    "d /var/lib/servarr/prowlarr         0755 servarr servarr -"
    "d /var/lib/servarr/radarr           0755 servarr servarr -"
    "d /var/lib/servarr/sonarr           0755 servarr servarr -"
    "d /var/lib/servarr/lidarr           0755 servarr servarr -"
    "d /var/lib/servarr/bazarr           0755 servarr servarr -"
    "d /var/lib/servarr/jellyseerr       0755 servarr servarr -"
    "d /ssd/downloads                    0775 servarr servarr -"
    "d /ssd/downloads/movies             0775 servarr servarr -"
    "d /ssd/downloads/music              0775 servarr servarr -"
    "d /ssd/downloads/complete           0775 servarr servarr -"
    "d /ssd/downloads/incomplete         0775 servarr servarr -"
    "d /etc/servarr                      0750 root    servarr -"
    # Empty env files — edit to add secrets after first boot
    "f /etc/servarr/qbittorrent.env  0640 root servarr -"
    "f /etc/servarr/prowlarr.env     0640 root servarr -"
    "f /etc/servarr/radarr.env       0640 root servarr -"
    "f /etc/servarr/sonarr.env       0640 root servarr -"
    "f /etc/servarr/lidarr.env       0640 root servarr -"
    "f /etc/servarr/bazarr.env       0640 root servarr -"
    "f /etc/servarr/jellyseerr.env   0640 root servarr -"
  ];

  # Expose all service WebUIs on LAN + Tailscale.
  # Port 1055 allows qbittorrent container to reach the Tailscale SOCKS5 proxy.
  networking.firewall.allowedTCPPorts = [
    1055  # Tailscale SOCKS5 proxy (servarr bridge access)
    5252  # qBittorrent WebUI
    5055  # Jellyseerr
    6767  # Bazarr
    7878  # Radarr
    8686  # Lidarr
    8989  # Sonarr
    9696  # Prowlarr
  ];

  networking.nftables.enable = true;
}

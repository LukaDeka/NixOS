# Media automation stack via nixarr
# https://nixarr.com/nixos-options/
#
# SETUP REQUIRED:
#   1. Add nixarr to flake.nix (see bottom of file)
#   2. Deploy tailscale-qbt.nix alongside this file (the SOCKS5 proxy daemon)
#   3. After deploying, authenticate the second Tailscale instance (see tailscale-qbt.nix)
#   4. After first boot, configure Prowlarr indexers via web UI (port 9696)
#   5. Add API keys for Recyclarr (see nixarr.recyclarr.configuration below)
#
# HOW TORRENTING IS ISOLATED:
#   A second tailscaled runs in userspace mode, exposing a SOCKS5 proxy on
#   127.0.0.1:1055 that routes all traffic through your chosen exit node.
#   qbittorrent is configured to use that proxy for ALL connections.
#   nftables blocks the qbittorrent user from connecting anywhere except
#   that proxy port and loopback — the kernel enforces the killswitch.
#   Your primary Tailscale instance and all other services are unaffected.
#
# JELLYFIN LIBRARY PATHS (add in Jellyfin UI):
#   Movies + TV  -> /ssd/downloads/movies
#   Music        -> /ssd/downloads/music
#
# In Sonarr: Settings > Media Management > Root Folders -> /ssd/downloads/movies
# In Radarr: Settings > Media Management > Root Folders -> /ssd/downloads/movies
# In Lidarr: Settings > Media Management > Root Folders -> /ssd/downloads/music

{ config, pkgs, ... }:

let
  mediaDir = "/ssd/downloads";
  stateDir = "/ssd/.state/nixarr";
  qbtUser = "qbittorrent";
  # SOCKS5 proxy exposed by the second tailscaled (see tailscale-qbt.nix)
  socksHost = "127.0.0.1";
  socksPort = 1055;
in
{
  nixarr = {
    enable = true;
    mediaDir = mediaDir;
    stateDir = stateDir;

    qbittorrent = {
      enable = true;
      openFirewall = true;

      # Route ALL qbittorrent traffic through the SOCKS5 proxy exposed by
      # the second tailscaled instance (tailscale-qbt.nix).
      # nftables (below) enforces this at the kernel level as a killswitch.
      extraConfig = {
        Preferences.Connection.ProxyType = 2;           # 2 = SOCKS5
        Preferences.Connection.ProxyAddress = socksHost;
        Preferences.Connection.ProxyPort = socksPort;
        Preferences.Connection.ProxyPeerConnections = true;  # proxy peer traffic too
        Preferences.Connection.ProxyHostnameLookup = true;   # proxy DNS (no leaks)
        Preferences.Connection.ProxyBitTorrent = true;       # proxy all BT traffic
        Preferences.Connection.UPnP = false;
      };

      exporter.enable = true;
    };

    # ── Indexer aggregator ───────────────────────────────────────────────────
    prowlarr = {
      enable = true;
      openFirewall = true;
      settings-sync.enable-nixarr-apps = true;
    };

    # ── Movie automation ─────────────────────────────────────────────────────
    radarr = {
      enable = true;
      openFirewall = true;
      settings-sync.downloadClients = [
        {
          name = "qBittorrent";
          enable = true;
          implementation = "QBittorrent";
          fields = {
            host = "127.0.0.1";
            port = 5252;
            movieCategory = "radarr";
          };
        }
      ];
      exporter.enable = true;
    };

    # ── TV/Series automation ─────────────────────────────────────────────────
    sonarr = {
      enable = true;
      openFirewall = true;
      settings-sync.downloadClients = [
        {
          name = "qBittorrent";
          enable = true;
          implementation = "QBittorrent";
          fields = {
            host = "127.0.0.1";
            port = 5252;
            tvCategory = "sonarr";
          };
        }
      ];
      exporter.enable = true;
    };

    # ── Music automation ─────────────────────────────────────────────────────
    lidarr = {
      enable = true;
      openFirewall = true;
      exporter.enable = true;
    };

    # ── Subtitle automation ──────────────────────────────────────────────────
    bazarr = {
      enable = true;
      openFirewall = true;
      settings-sync.radarr.enable = true;
      settings-sync.sonarr.enable = true;
    };

    # ── Media request portal ─────────────────────────────────────────────────
    seerr = {
      enable = true;
      openFirewall = true;
    };

    # ── Quality profile sync (TRaSH Guides) ──────────────────────────────────
    recyclarr = {
      enable = true;
      schedule = "weekly";
      configuration = {
        sonarr.main = {
          base_url = "http://127.0.0.1:8989";
          # Get from Sonarr UI: Settings > General > API Key
          api_key = "!env_var SONARR_API_KEY";
          quality_definition.type = "series";
          quality_profiles = [
            {
              name = "WEB-1080p";
              upgrade = {
                allowed = true;
                until_quality = "WEB 1080p";
                until_score = 10000;
              };
              min_format_score = 0;
              quality_sort = "top";
              qualities = [
                { name = "WEB 1080p"; qualities = [ "WEBDL-1080p" "WEBRip-1080p" ]; }
              ];
            }
          ];
        };
        radarr.main = {
          base_url = "http://127.0.0.1:7878";
          # Get from Radarr UI: Settings > General > API Key
          api_key = "!env_var RADARR_API_KEY";
          quality_definition.type = "movie";
          quality_profiles = [
            {
              name = "HD Bluray + WEB";
              upgrade = {
                allowed = true;
                until_quality = "Bluray-1080p";
                until_score = 10000;
              };
              min_format_score = 0;
              quality_sort = "top";
              qualities = [
                { name = "Bluray-1080p"; }
                { name = "WEB 1080p"; qualities = [ "WEBDL-1080p" "WEBRip-1080p" ]; }
              ];
            }
          ];
        };
      };
    };
  };

  # systemd.services.recyclarr.serviceConfig.EnvironmentFile = "/etc/env/nixarr/recyclarr.env";

  # ── Auth: required by nixarr settings-sync assertions ───────────────────────
  # "DisabledForLocalAddresses" means auth is skipped for loopback/LAN requests,
  # which is safe since all these services only listen on localhost.
  services.prowlarr.settings.auth.required = "DisabledForLocalAddresses";
  services.radarr.settings.auth.required = "DisabledForLocalAddresses";
  services.sonarr.settings.auth.required = "DisabledForLocalAddresses";
  services.lidarr.settings.auth.required = "DisabledForLocalAddresses";

  # ── Killswitch: nftables rules loaded at runtime ─────────────────────────────
  # Loaded via a systemd service so skuid resolves after the qbittorrent user
  # is created (nftables build-time validation runs in a sandbox without users).
  # The qbittorrent service depends on this, so the rules are always in place first.
  networking.nftables.enable = true;

  systemd.services.qbittorrent-killswitch = {
    description = "qbittorrent nftables killswitch";
    wantedBy = [ "multi-user.target" ];
    before = [ "qbittorrent.service" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "qbittorrent-killswitch-start" ''
        ${pkgs.nftables}/bin/nft add table inet qbittorrent_killswitch
        ${pkgs.nftables}/bin/nft 'add chain inet qbittorrent_killswitch output { type filter hook output priority 0; policy accept; }'
        ${pkgs.nftables}/bin/nft add rule inet qbittorrent_killswitch output oifname lo skuid ${qbtUser} accept
        ${pkgs.nftables}/bin/nft add rule inet qbittorrent_killswitch output skuid ${qbtUser} drop
      '';
      ExecStop = pkgs.writeShellScript "qbittorrent-killswitch-stop" ''
        ${pkgs.nftables}/bin/nft delete table inet qbittorrent_killswitch || true
      '';
    };
  };

  # ── Firewall ports ───────────────────────────────────────────────────────────
  networking.firewall.allowedTCPPorts = [
    5055  # Jellyseerr
    5252  # qBittorrent WebUI
    6767  # Bazarr
    7878  # Radarr
    8686  # Lidarr
    8989  # Sonarr
    9696  # Prowlarr
  ];
}

# ── FLAKE INTEGRATION ────────────────────────────────────────────────────────
# 1. Add to flake.nix inputs:
#
#      nixarr.url = "github:rasmus-kirk/nixarr";
#      nixarr.inputs.nixpkgs.follows = "nixpkgs";
#
# 2. Add nixarr to the outputs function args:
#      { nixpkgs, nixpkgs-stable, disko, nixarr, ... } @ inputs:
#
# 3. Add to conway modules list:
#      inputs.nixarr.nixosModules.default
#      ./packages/nixarr.nix
#
# 4. Set Tailscale exit node (run once, or add to tailscale.nix extraSetFlags):
#      tailscale set --exit-node=<exit-node-ip> --exit-node-allow-lan-access=true
#
# 5. Set API keys for Recyclarr (e.g. via agenix/sops or a plain secrets file):
#      systemd.services.recyclarr.serviceConfig.EnvironmentFile = "/etc/nixarr/secrets.env";
#    File contents:
#      SONARR_API_KEY=xxxx
#      RADARR_API_KEY=xxxx

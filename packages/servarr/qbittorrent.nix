{ pkgs, ... }:

# qbittorrent — torrent client
# WebUI: http://<host>:5252  (default user: admin, password in service logs on first start)
#
# SOCKS5 killswitch:
#   Container is assigned static IP 10.89.1.100.
#   nftables drops any FORWARD traffic from 10.89.1.100 destined outside
#   the servarr bridge (10.89.1.0/24). The SOCKS5 proxy on the host
#   (10.89.1.1:1055) is reached via INPUT — not FORWARD — so it is
#   unaffected. If the proxy is down, qbittorrent has no external path.
#
# SOCKS5 config is written to the config volume on first start by
# podman-qbittorrent-init.service.

{
  # Write qBittorrent.conf with SOCKS5 proxy pre-configured if it doesn't exist.
  # Runs before the container starts.
  systemd.services.podman-qbittorrent-init = {
    description = "Initialize qbittorrent SOCKS5 config";
    before = [ "podman-qbittorrent.service" ];
    wantedBy = [ "podman-qbittorrent.service" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      dir=/var/lib/servarr/qbittorrent/qBittorrent
      conf=$dir/qBittorrent.conf
      mkdir -p "$dir"
      chown -R 994:994 /var/lib/servarr/qbittorrent
      [ -f "$conf" ] && exit 0
      cat > "$conf" <<'EOF'
[BitTorrent]
Session\DefaultSavePath=/downloads/complete/
Session\TempPath=/downloads/incomplete/
Session\TempPathEnabled=true

[Network]
PortForwardingEnabled=false
Proxy\Host=10.89.1.1
Proxy\HostnameLookupEnabled=true
Proxy\Port=1055
Proxy\Profiles\BitTorrent=true
Proxy\Profiles\Misc=true
Proxy\Profiles\RSS=true
Proxy\Type=SOCKS5

[Preferences]
Connection\UPnP=false
WebUI\HostHeaderValidation=false
WebUI\Port=8080
WebUI\UseUHTTP=false
EOF
      chown 994:994 "$conf"
    '';
  };

  virtualisation.oci-containers.containers.qbittorrent = {
    image = "lscr.io/linuxserver/qbittorrent:latest";
    autoStart = true;
    networks = [ "servarr" ];

    # Static IP so the nftables killswitch can match it reliably
    extraOptions = [ "--ip=10.89.1.100" ];

    ports = [ "5252:8080" ];

    volumes = [
      "/var/lib/servarr/qbittorrent:/config"
      "/ssd/downloads:/downloads"
    ];

    environment = {
      PUID        = "994";
      PGID        = "994";
      TZ          = "Europe/Berlin";
      UMASK       = "002";
      WEBUI_PORT  = "8080";
      TORRENTING_PORT = "6881";
    };

    environmentFiles = [ "/etc/servarr/qbittorrent.env" ];
  };

  # nftables killswitch — IP-based, safe to evaluate at build time.
  # Drops any FORWARD packets from qbittorrent container that are NOT
  # destined for the servarr bridge (i.e., direct internet bypass attempts).
  # Drop NEW outbound connections from qbittorrent to the internet (direct bypass).
  # ESTABLISHED/RELATED packets (WebUI responses back to browser, etc.) are allowed.
  networking.nftables.tables.servarr-qbt-killswitch = {
    family = "inet";
    content = ''
      chain forward {
        type filter hook forward priority filter; policy accept;
        ip saddr 10.89.1.100 ip daddr != 10.89.1.0/24 ct state { new, untracked } drop
      }
    '';
  };
}

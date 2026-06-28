{ ... }:

# qbittorrent — WebUI: http://conway-qbt:8080 (via Tailscale)
# Password printed to logs on first start:
#   sudo journalctl -u podman-qbittorrent -n 20
# Reset: stop service, rm -rf /var/lib/servarr/qbittorrent/qBittorrent, restart

{
  systemd.services.podman-qbittorrent-init = {
    description = "Initialize qbittorrent config";
    before = [ "podman-qbittorrent.service" ];
    wantedBy = [ "podman-qbittorrent.service" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      dir=/var/lib/servarr/qbittorrent/qBittorrent
      conf=$dir/qBittorrent.conf
      mkdir -p "$dir"
      chown -R 994:994 /var/lib/servarr/qbittorrent
      if [ ! -f "$conf" ]; then
        cat > "$conf" <<'QBTEOF'
[BitTorrent]
Session\DefaultSavePath=/downloads/complete/
Session\Interface=tailscale-exit
Session\InterfaceName=tailscale-exit
Session\TempPath=/downloads/incomplete/
Session\TempPathEnabled=true

[Preferences]
Connection\UPnP=false
WebUI\Address=*
WebUI\HostHeaderValidation=false
WebUI\Port=8080
WebUI\ServerDomains=*
QBTEOF
        chown 994:994 "$conf"
      fi
    '';
  };

  virtualisation.oci-containers.containers.qbittorrent = {
    image = "lscr.io/linuxserver/qbittorrent:latest";
    autoStart = true;
    extraOptions = [ "--network=container:tailscale-qbt" ];
    volumes = [
      "/var/lib/servarr/qbittorrent:/config"
      "/ssd/downloads:/downloads"
    ];
    environment = {
      PUID            = "994";
      PGID            = "994";
      TZ              = "Europe/Berlin";
      UMASK           = "002";
      WEBUI_PORT      = "8080";
      TORRENTING_PORT = "6881";
    };
    environmentFiles = [ "/etc/env/servarr/qbittorrent.env" ];
  };

  systemd.services.podman-qbittorrent = {
    after    = [ "podman-tailscale-qbt.service" ];
    requires = [ "podman-tailscale-qbt.service" ];
    bindsTo  = [ "podman-tailscale-qbt.service" ];
  };
}

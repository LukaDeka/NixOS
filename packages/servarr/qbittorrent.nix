{ pkgs, ... }:

# qbittorrent — torrent client
# WebUI: http://<host>:5252
# Credentials: set in /etc/env/servarr/qbittorrent.env (WEBUI_USERNAME / WEBUI_PASSWORD)
#
# SOCKS5 killswitch:
#   Container is assigned static IP 10.89.1.100.
#   nftables drops any FORWARD traffic from 10.89.1.100 destined outside
#   the servarr bridge (10.89.1.0/24). The SOCKS5 proxy on the host
#   (10.89.1.1:1055) is reached via INPUT — not FORWARD — so it is
#   unaffected. If the proxy is down, qbittorrent has no external path.
#
# To force re-init (e.g. after credential change):
#   sudo systemctl stop podman-qbittorrent
#   sudo rm /var/lib/servarr/qbittorrent/qBittorrent/qBittorrent.conf
#   sudo systemctl restart podman-qbittorrent-init podman-qbittorrent

{
  systemd.services.podman-qbittorrent-init = {
    description = "Initialize qbittorrent config";
    before = [ "podman-qbittorrent.service" ];
    wantedBy = [ "podman-qbittorrent.service" ];
    path = [ pkgs.python3 ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      dir=/var/lib/servarr/qbittorrent/qBittorrent
      conf=$dir/qBittorrent.conf
      mkdir -p "$dir"
      chown -R 994:994 /var/lib/servarr/qbittorrent
      [ -f "$conf" ] && exit 0

      WEBUI_USERNAME=admin
      WEBUI_PASSWORD=admin
      envfile=/etc/env/servarr/qbittorrent.env
      if [ -f "$envfile" ]; then
        val=$(grep '^WEBUI_USERNAME=' "$envfile" | cut -d= -f2-)
        [ -n "$val" ] && WEBUI_USERNAME=$val
        val=$(grep '^WEBUI_PASSWORD=' "$envfile" | cut -d= -f2-)
        [ -n "$val" ] && WEBUI_PASSWORD=$val
      fi

      PASS_HASH=$(python3 - "$WEBUI_PASSWORD" <<'PYEOF'
import hashlib, os, base64, sys
pw = sys.argv[1].encode()
salt = os.urandom(16)
dk = hashlib.pbkdf2_hmac('sha1', pw, salt, 100000, dklen=64)
print('@ByteArray(' + base64.b64encode(salt).decode() + ':' + base64.b64encode(dk).decode() + ')')
PYEOF
)

      cat > "$conf" <<EOF
[BitTorrent]
Session\DefaultSavePath=/downloads/complete/
Session\TempPath=/downloads/incomplete/
Session\TempPathEnabled=true

[Network]
PortForwardingEnabled=false
Proxy\AuthEnabled=false
Proxy\HostnameLookupEnabled=true
Proxy\IP=10.89.1.1
Proxy\Password=
Proxy\Port=@Variant(\0\0\0\x85\x4\x1f)
Proxy\Profiles\BitTorrent=true
Proxy\Profiles\Misc=true
Proxy\Profiles\RSS=true
Proxy\Type=SOCKS5
Proxy\Username=

[Preferences]
Connection\UPnP=false
WebUI\Address=*
WebUI\HostHeaderValidation=false
WebUI\Port=8080
WebUI\ServerDomains=*
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
      PUID            = "994";
      PGID            = "994";
      TZ              = "Europe/Berlin";
      UMASK           = "002";
      WEBUI_PORT      = "8080";
      TORRENTING_PORT = "6881";
    };

    environmentFiles = [ "/etc/servarr/qbittorrent.env" ];
  };

  # nftables killswitch: drops NEW outbound connections from qbittorrent to
  # the internet. ESTABLISHED/RELATED (WebUI responses to browser) are allowed.
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

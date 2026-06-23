{ ... }:

# Sonarr — TV series automation
# WebUI: http://<host>:8989
#
# After first boot:
#   Settings > Media Management > Root Folders → /tv
#   Settings > Download Clients → Add qBittorrent:
#     Host: qbittorrent   Port: 8080   Category: sonarr
#   Settings > General → copy API key → add to Prowlarr Settings > Apps

{
  virtualisation.oci-containers.containers.sonarr = {
    image = "lscr.io/linuxserver/sonarr:latest";
    autoStart = true;
    networks = [ "servarr" ];
    ports = [ "8989:8989" ];

    volumes = [
      "/var/lib/servarr/sonarr:/config"
      "/ssd/downloads/movies:/tv"
      "/ssd/downloads:/downloads"
    ];

    environment = {
      PUID  = "994";
      PGID  = "994";
      TZ    = "Europe/Berlin";
      UMASK = "002";
    };

    environmentFiles = [ "/etc/servarr/sonarr.env" ];
  };
}

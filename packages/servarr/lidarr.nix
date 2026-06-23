{ ... }:

# Lidarr — music automation
# WebUI: http://<host>:8686
#
# After first boot:
#   Settings > Media Management > Root Folders → /music
#   Settings > Download Clients → Add qBittorrent:
#     Host: qbittorrent   Port: 8080   Category: lidarr
#   Settings > General → copy API key → add to Prowlarr Settings > Apps

{
  virtualisation.oci-containers.containers.lidarr = {
    image = "lscr.io/linuxserver/lidarr:latest";
    autoStart = true;
    networks = [ "servarr" ];
    ports = [ "8686:8686" ];

    volumes = [
      "/var/lib/servarr/lidarr:/config"
      "/ssd/downloads/music:/music"
      "/ssd/downloads:/downloads"
    ];

    environment = {
      PUID  = "994";
      PGID  = "994";
      TZ    = "Europe/Berlin";
      UMASK = "002";
    };

    environmentFiles = [ "/etc/servarr/lidarr.env" ];
  };
}

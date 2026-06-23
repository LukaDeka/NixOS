{ ... }:

# Radarr — movie automation
# WebUI: http://<host>:7878
#
# After first boot:
#   Settings > Media Management > Root Folders → /movies
#   Settings > Download Clients → Add qBittorrent:
#     Host: qbittorrent   Port: 8080   Category: radarr
#   Settings > General → copy API key → add to Prowlarr Settings > Apps

{
  virtualisation.oci-containers.containers.radarr = {
    image = "lscr.io/linuxserver/radarr:latest";
    autoStart = true;
    networks = [ "servarr" ];
    ports = [ "7878:7878" ];

    volumes = [
      "/var/lib/servarr/radarr:/config"
      "/ssd/downloads/movies:/movies"
      "/ssd/downloads:/downloads"
    ];

    environment = {
      PUID  = "994";
      PGID  = "994";
      TZ    = "Europe/Berlin";
      UMASK = "002";
    };

    environmentFiles = [ "/etc/servarr/radarr.env" ];
  };
}

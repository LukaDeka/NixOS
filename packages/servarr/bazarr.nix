{ ... }:

# Bazarr — subtitle automation
# WebUI: http://<host>:6767
#
# After first boot:
#   Settings > Radarr → Host: radarr   Port: 7878   paste API key
#   Settings > Sonarr → Host: sonarr   Port: 8989   paste API key
#   Settings > Providers → add OpenSubtitles or preferred provider

{
  virtualisation.oci-containers.containers.bazarr = {
    image = "lscr.io/linuxserver/bazarr:latest";
    autoStart = true;
    networks = [ "servarr" ];
    ports = [ "6767:6767" ];

    volumes = [
      "/var/lib/servarr/bazarr:/config"
      "/ssd/downloads/movies:/movies"
      "/ssd/downloads/movies:/tv"
      "/ssd/downloads/music:/music"
    ];

    environment = {
      PUID  = "994";
      PGID  = "994";
      TZ    = "Europe/Berlin";
      UMASK = "002";
    };

    environmentFiles = [ "/etc/servarr/bazarr.env" ];
  };
}

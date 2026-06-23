{ ... }:

# Prowlarr — indexer aggregator
# WebUI: http://<host>:9696
# Add torrent indexers here; sync them to Radarr/Sonarr/Lidarr via Settings > Apps.
# Use container hostnames: radarr:7878, sonarr:8989, lidarr:8686

{
  virtualisation.oci-containers.containers.prowlarr = {
    image = "lscr.io/linuxserver/prowlarr:latest";
    autoStart = true;
    networks = [ "servarr" ];
    ports = [ "9696:9696" ];

    volumes = [
      "/var/lib/servarr/prowlarr:/config"
    ];

    environment = {
      PUID  = "994";
      PGID  = "994";
      TZ    = "Europe/Berlin";
      UMASK = "002";
    };

    environmentFiles = [ "/etc/servarr/prowlarr.env" ];
  };
}

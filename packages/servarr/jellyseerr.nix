{ ... }:

# Jellyseerr — media request portal
# WebUI: http://<host>:5055
#
# After first boot:
#   Sign in with Jellyfin account → Server: http://10.10.10.10:8096
#   Settings > Radarr  → Host: radarr   Port: 7878   paste API key   Root: /movies
#   Settings > Sonarr  → Host: sonarr   Port: 8989   paste API key   Root: /tv

{
  virtualisation.oci-containers.containers.jellyseerr = {
    image = "fallenbagel/jellyseerr:latest";
    autoStart = true;
    networks = [ "servarr" ];
    ports = [ "5055:5055" ];

    volumes = [
      "/var/lib/servarr/jellyseerr:/app/config"
    ];

    environment = {
      TZ = "Europe/Berlin";
    };

    environmentFiles = [ "/etc/servarr/jellyseerr.env" ];
  };
}

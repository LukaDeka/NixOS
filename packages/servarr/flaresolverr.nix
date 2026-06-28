{ ... }:

# FlareSolverr — Cloudflare challenge bypass proxy for Prowlarr indexers
# WebUI/API: http://<host>:8191 (also reachable inside the network as flaresolverr:8191)
# Configure in Prowlarr: Settings > Indexers > Add Proxy > FlareSolverr
# Proxy URL: http://flaresolverr:8191

{
  virtualisation.oci-containers.containers.flaresolverr = {
    image = "ghcr.io/flaresolverr/flaresolverr:latest";
    autoStart = true;
    networks = [ "servarr" ];
    ports = [ "8191:8191" ];

    environment = {
      LOG_LEVEL = "info";
      TZ        = "Europe/Berlin";
    };
  };
}

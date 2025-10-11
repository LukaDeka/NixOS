{ config, ... }:

let
  domain = config.vars.domain;
in
{
  services.nginx.virtualHosts."jellyfin.${domain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://conway:8096";
      proxyWebsockets = true;
    };
  };
}


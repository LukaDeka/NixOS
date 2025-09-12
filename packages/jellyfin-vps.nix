{ config, ... }:

let
  domain = config.vars.domain;
  ip = config.vars.serverNetbirdIp;
in
{
  services.nginx.virtualHosts."jellyfin.${domain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${ip}:8096";
      proxyWebsockets = true;
    };
  };
}

